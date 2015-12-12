{-# LANGUAGE FlexibleInstances      #-}
{-# LANGUAGE DeriveGeneric          #-}
{-# LANGUAGE FunctionalDependencies #-}
{-# LANGUAGE MultiParamTypeClasses  #-}
{-# LANGUAGE TemplateHaskell        #-}
{-# LANGUAGE TypeSynonymInstances   #-}
{-# LANGUAGE RecordWildCards        #-}
{-# LANGUAGE OverloadedStrings      #-}
module Models.Timeline where

import Models.General
import Models.Discussion
import Models.Event
import Data.Time        (UTCTime(..),fromGregorian)
import Data.Maybe       (fromMaybe)
import Data.List        (sort,sortBy)
import Data.Dynamic
import Servant.Docs     (ToSample(..))

data Timeline = Timeline 
    { timelineTill      :: UTCTime
    , timelineContents   :: [Meta] 
    } deriving (Generic, Show)

instance ToJSON Timeline where 
    toJSON = toJSONPrefixed

data Meta = Meta 
    { metaHappened       :: UTCTime
    , metaContent       :: Content
    , metaType          :: String
    , metaSuperType     :: String
    } deriving (Generic, Show)

instance ToJSON Meta where 
    toJSON = toJSONPrefixed

data Content = ContentDiscussion Discussion 
             | ContentEvent Event
             deriving Show

instance HasHappened Content where
    happened (ContentDiscussion x) = happened x
    happened (ContentEvent x) = happened x

instance HasType Content where
    getType (ContentDiscussion x) = getType x
    getType (ContentEvent x) = getType x
    getSuperType (ContentDiscussion x) = getSuperType x
    getSuperType (ContentEvent x) = getSuperType x

instance ToJSON Content where
    toJSON (ContentDiscussion x) = toJSON x
    toJSON (ContentEvent x)     = toJSON x

instance ToSample Timeline Timeline where
    toSamples _ = [ ("Timeline for 20th Dec 2015", sampleTimeline1)
                  , ("Timeline for 25th Dec 2015", sampleTimeline2)
                  ]

timeline :: Maybe UTCTime -> UTCTime -> [Content] -> Timeline
timeline (Just from) till content = timeline Nothing till $ filter (\x -> happened x > from) content
timeline _ till content = Timeline till 
    $ map attachMeta 
    $ sortBy (\x y -> compare (happened y) (happened x)) 
    $ filter (\x -> happened x < till) content

attachMeta :: Content -> Meta
attachMeta c = Meta (happened c) c (getType c) (getSuperType c)

sampleTimeline1 = sampleTimeline (UTCTime (fromGregorian 2015 12 20) (60*60*2))
sampleTimeline2 = sampleTimeline (UTCTime (fromGregorian 2015 12 25) (60*60*12))
sampleTimeline till = timeline Nothing till 
    [ ContentDiscussion sampleDiscussionParent
    , ContentEvent sampleEvent1
    , ContentEvent sampleEvent2
    ]
