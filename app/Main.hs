module Main where

import Data.Semigroup ((<>))
import Data.Text
import Options.Applicative

import Lib

data Command =
  Add Text
  deriving (Show)

data Opts = Opts
  { optCommand :: Command
  }

main :: IO ()
main = do
  opts <- showHelpOnErrorExecParser optsParser
  _ <-
    case optCommand opts of
      Add dep -> addDependency dep

showHelpOnErrorExecParser :: ParserInfo a -> IO a
showHelpOnErrorExecParser = customExecParser (prefs showHelpOnError)

progDescStr :: String
progDescStr = "Add libraries to package.yaml dependencies"

optsParser :: ParserInfo Opts
optsParser =
  info
    (helper <*> versionOption <*> programOptions)
    (fullDesc <> progDesc "Add libraries to package.yaml dependencies")

versionOption :: Parser (a -> a)
versionOption = infoOption "0.0" (long "version" <> help "Show version")

programOptions :: Parser Opts
programOptions = Opts <$> hsubparser (addCommand)

addCommand :: Mod CommandFields Command
addCommand =
  command
    "add"
    (info addCommandOptions (progDesc "add a dependency to package.yaml"))

addCommandOptions :: Parser Command
addCommandOptions =
  Add <$> strArgument (metavar "NAME" <> help "Name of the library")
