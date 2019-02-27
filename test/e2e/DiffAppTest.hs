-- | Test the Radicle diff app.
module DiffAppTest
    ( test_diff_propose
    ) where

import           Protolude

import           Test.E2ESupport

test_diff_propose :: TestTree
test_diff_propose = testCaseSteps "diff propose" $ \step -> do
    step "Init project"
    _ <- runTestCommand "rad-create-keys" []
    _ <- runTestCommand "git" ["config", "--global", "user.name", "Alice"]
    _ <- runTestCommand "git" ["config", "--global", "user.email", "alice@example.com"]
    _ <- runTestCommand' "rad-project" ["init"] ["project-name", "project desc", "1"]
    _ <- runTestCommand "touch" ["test"]
    _ <- runTestCommand "git" ["add", "test"]
    _ <- runTestCommand "git" ["commit", "--message", "first commit"]
    commitSha <- runTestCommand "git" ["rev-parse", "--short", "HEAD"]

    step "rad diff propose"
    _ <- runTestCommand "rad-diff" ["propose", "HEAD"]

    listOutput <- runTestCommand "rad-diff" ["list"]
    assertContains listOutput $ "state      #"
    assertContains listOutput $ "pending    0"

    showOutput <- runTestCommand "rad-diff" ["show", "0"]
    assertContains showOutput $ "pending 0"
    assertContains showOutput $ "From " <> commitSha
    assertContains showOutput $ "Comments\n---"