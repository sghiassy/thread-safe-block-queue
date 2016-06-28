# thread-safe-block-queue

[![CI Status](https://travis-ci.org/sghiassy/thread-safe-block-queue.svg?branch=master)](https://travis-ci.org/Shaheen Ghiassy/thread-safe-block-queue)
[![Version](https://img.shields.io/cocoapods/v/thread-safe-block-queue.svg?style=flat)](http://cocoapods.org/pods/thread-safe-block-queue)
[![License](https://img.shields.io/cocoapods/l/thread-safe-block-queue.svg?style=flat)](http://cocoapods.org/pods/thread-safe-block-queue)
[![Platform](https://img.shields.io/cocoapods/p/thread-safe-block-queue.svg?style=flat)](http://cocoapods.org/pods/thread-safe-block-queue)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

thread-safe-block-queue is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "thread-safe-block-queue"
```

## Description

```
//   ┌────────────────────────────────┐
//   │  Queue starts at HEAD with 0   │
//   └────────────────────────────────┘
//       │
//       │
//       │
//       │
//       │
//       │
//       ▼
//
//      null
//
//
//
//
//
//
//   ┌─────────────────────────────────────────────┐
//   │     Blocks come in and are queued FIFO      │
//   └─────────────────────────────────────────────┘
//       │
//       │
//       │
//       │
//       │
//       │
//       ▼
//  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
//  │         │ │         │ │         │ │         │ │         │
//  │  Block  │ │  Block  │ │  Block  │ │  Block  │ │  Block  │
//  │         │ │         │ │         │ │         │ │         │
//  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
//
//
//
//
//
//
//
//
//   ┌───────────────────────────────────────────────────────────────────────────────┐
//   │ Dequeuing the data structure causes the blocks to be run in sequential order  │
//   └───────────────────────────────────────────────────────────────────────────────┘
//                                                       │
//                                                       │
//                                                       │
//          ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ▶  │
//                                                       │
//                                                       │
//       ▼                                               ▼
//  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
//  │         │ │         │ │         │ │         │ │         │
//  │  Block  │ │  Block  │ │  Block  │ │  Block  │ │  Block  │
//  │         │ │         │ │         │ │         │ │         │
//  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
//
//
//
//
//
//
//
//
//
//
//                                        ┌──────────────────────────────────────────┐
//                                        │Subsequent blocks will be run immediately │
//                                        └──────────────────────────────────────────┘
//                                                                   │
//                                                                   │
//                                                        ─ ─ ─ ─ ─▶ │
//                                                                   │
//                                                                   │
//                                                                   │
//                                                       ▼           ▼
//  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
//  │         │ │         │ │         │ │         │ │         │ │         │
//  │  Block  │ │  Block  │ │  Block  │ │  Block  │ │  Block  │ │  Block  │
//  │         │ │         │ │         │ │         │ │         │ │         │
//  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
//
//
//
//
//
//
//
//
//
//
//
//
//    ┌────────────────────────────────────────────────────────────┐
//    │  Hitting replay will cause the queue to be rerun in FIFO   │
//    └────────────────────────────────────────────────────────────┘
//
//       ╳                                                           │
//       ╳                                                           │
//       ╳  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─replay ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─▶ │
//       ╳                                                           │
//       ╳                                                           │
//       ╳                                                           │
//       ▼                                                           ▼
//  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
//  │         │ │         │ │         │ │         │ │         │ │         │
//  │  Block  │ │  Block  │ │  Block  │ │  Block  │ │  Block  │ │  Block  │
//  │         │ │         │ │         │ │         │ │         │ │         │
//  └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
//
//
//
//
//
//
//
//
//
//
//
//
//
//   ┌─────────────────────────────────────────────────────────────────────────────────────────────────────────┐
//   │    Should new blocks be added during replay mode they will simply be appended and run in FIFO order     │
//   └─────────────────────────────────────────────────────────────────────────────────────────────────────────┘
//
//                               ╳                                             │
//                               ╳                                             │
//                               ╳  ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─▶ │
//                               ╳                     replay                  │
//                               ╳                                             │
//                               ╳                                             │
//                               ▼                                             ▼
// ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐
// │         │ │         │ │         │ │         │ │         │ │         │ │         │
// │  Block  │ │  Block  │ │  Block  │ │  Block  │ │  Block  │ │  Block  │ │  Block  │
// │         │ │         │ │         │ │         │ │         │ │         │ │         │
// └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘ └─────────┘
```

## Author

Shaheen Ghiassy, shaheen.ghiassy@gmail.com

## License

thread-safe-block-queue is available under the MIT license. See the LICENSE file for more info.
