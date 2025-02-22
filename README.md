# SoftAwake

Do you ever wake up feeling groggy, even after a full night’s sleep? It’s frustrating, right? Often, it’s because you woke up during a deep sleep phase. SoftAwake is designed to fix that by waking you up during a lighter sleep stage, helping you start your day feeling refreshed and energized.

## About

SoftAwake is an open-source iOS app that uses sleep data from Apple’s HealthKit to analyze your sleep stages. If you wear an Apple Watch to bed, it provides accurate insights into your sleep patterns. SoftAwake then uses this data to wake you up at the optimal time within a window you set—say goodbye to groggy mornings!

## Features

- Sleep Stage Analysis: Harnesses [HKCategoryValueSleepAnalysis](https://developer.apple.com/documentation/healthkit/hkcategoryvaluesleepanalysis) to track your sleep patterns accurately.
- Smart Wake-Up: Finds the best moment to wake you up based on your sleep stages.
- Better Mornings: Reduces grogginess by aligning your alarm with your natural sleep cycle.

## Why Open Source?

While building SoftAwake, I ran into a hurdle: You can't access HealthKit data when your phone is locked, which is tricky for an app that works overnight. Instead of keeping it as a closed product with limitations, I decided to open-source it.

## Installation

Getting SoftAwake up and running is simple:
1. Clone the repository:  
  `git clone https://github.com/Pythonen/SoftAwake.git`
2. Open the .xcodeproj file in Xcode.
3. Build and run the app on your iOS device.

## Usage

Here’s how to use SoftAwake:
Launch the app and grant permission to access your HealthKit data.
Set your preferred wake-up time.
Wear your Apple Watch to bed to track your sleep stages.
Go to sleep—SoftAwake will wake you up at the best time within your window.

## Contributing

Contributions to SoftAwake are welcome from developers, designers, and anyone interested in improving sleep quality.

## License

SoftAwake is released under the MIT License. See the LICENSE file for details.

## Contact

Got questions, ideas, or feedback? Feel free to open an issue on GitHub or email me at [aleksi.puttonen@gmail.com (mailto:aleksi.puttonen@gmail.com)].
