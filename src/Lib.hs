module Lib
  ( addDependency
  ) where

import Control.Lens
import Data.Aeson.Lens
import qualified Data.Vector as Vector
import qualified Data.Text as Text
import Data.Yaml

packageYaml :: String
packageYaml = "package.yaml"

addDependency :: Text.Text -> IO ()
addDependency dependency = do
  packageStr :: Value <- decodeFileThrow packageYaml
  encodeFile packageYaml $ updateDependencies dependency packageStr

updateDependencies :: Text.Text -> Value -> Value
updateDependencies dependency fileContents =
    fileContents & key "dependencies" %~ (handleDeps dependency)

handleDeps :: Text.Text -> Value -> Value
handleDeps candidateDep dependencies =
  case dependencies of
    Array deps ->
        if hasDependency candidateDep deps then
            Array deps 
        else
            insertDependency candidateDep deps
    _ -> dependencies

insertDependency :: Text.Text -> Vector.Vector Value -> Value
insertDependency dependency dependencies =
  let insertAt =
        Vector.findIndex (\dep -> smallerThan dependency dep) dependencies
   in case insertAt of
        Just insertAtIndex ->
          let (firstPart, secondPart) =
                Vector.splitAt insertAtIndex dependencies
           in Array $
              Vector.concat
                [Vector.snoc firstPart (String dependency), secondPart]
        Nothing -> Array $ Vector.snoc dependencies (String dependency)

    
smallerThan :: Text.Text -> Value -> Bool
smallerThan newDep existingDep =
    case existingDep of
        String val -> newDep < val
        _ -> False

hasDependency :: Text.Text -> Vector.Vector Value -> Bool
hasDependency candidateDep dependencies =
    case Vector.find (\dep -> depsMatch candidateDep dep) dependencies of
        Just _ -> True
        Nothing -> False

depsMatch :: Text.Text -> Value -> Bool
depsMatch candidateDep existingDep =
    case existingDep of
        String depName ->
            let packageName dep =
                    let depBits = Text.words dep
                    in case depBits of
                        [] -> Nothing
                        (x:_) -> Just x
            in case packageName depName of
                    Just package -> candidateDep == package
                    Nothing -> False
        _ -> False
