module Docs where

import Waku.APIs.TimelineAPI
import Servant.Docs

apiDocs :: API
apiDocs = docs timelineAPI
updateDocs = writeFile "timeline-service.md" $ markdown apiDocs

main = updateDocs
