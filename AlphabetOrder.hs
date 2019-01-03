-- vim: set et ts=4 sw=4:
import Data.Maybe
import System.Exit
import System.Random  -- random
import UI.NCurses  -- ncurses

select :: [a] -> IO a
select xs = (xs !!) <$> randomRIO (0, (length xs) - 1)

-- getEvent should've really have been two functions
-- a return value of Nothing is not possible when the timeout is Nothing, forcing us to do a fromJust
getEventBlocking :: Window -> Curses Event
getEventBlocking w = fromJust <$> getEvent w Nothing

main :: IO ()
main = do
    window <- runCurses $ do
        window <- defaultWindow
        _ <- setCursorMode CursorInvisible
        updateWindow window $ drawString $ "Pick the letter that comes first (left/right arrow, anything else quits)\n\n"
        return window
    sequence_ $ repeat $ do
        c1 <- select ['a'..'z']
        c2 <- select (['a'..pred c1] ++ [succ c1..'z'])  --don't want duplicate characters
        event <- runCurses $ do
            updateWindow window $ drawString $ c1:' ':c2:[]
            render
            event <- getEventBlocking window
            updateWindow window $ moveCursor 1 0
            -- TODO Ctrl-C handling is a mess for some reason; Ctrl-C doesn't take effect until one more key is pressed
            -- ncurses doesn't seem to have an event for that, so I suspect only a library switch will solve this
            return event
        case event of
            EventSpecialKey KeyRightArrow -> runCurses $ updateWindow window $ drawString $ if c1 > c2 then "Yes\n" else "No\n"
            EventSpecialKey KeyLeftArrow -> runCurses $ updateWindow window $ drawString $ if c1 < c2 then "Yes\n" else "No\n"
            _ -> runCurses (closeWindow window) >> exitSuccess
