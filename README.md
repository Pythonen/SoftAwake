# SoftAwake

Do you hate waking up from deep sleep as much as I do? No worries! There are solutions for that... but they cost you money.
Now, I don't like that either. So let's spend countless hours building our own solution :')

## What is this?

SoftAwake works (at some point) just like your normal alarm clock, but with a twist. It uses Apple's [Healthkit sleep analysis API](https://developer.apple.com/documentation/healthkit/hkcategoryvaluesleepanalysis) to track your sleep (don't know how it works without Apple Watch, so assuming you have one) and uses that to wake you up when you're in your light sleep. Current target is to wake you up within 30 minutes of your target time.

Once your set time is within 30 minutes, the app starts to measure your sleep, and if it detects light sleep, it'll fire the alarm off.
