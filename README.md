# ChessMelee
AI Driven "Melee" Style Chess

![demo](https://github.com/chessboy/ChessMelee/blob/master/demo.gif)

## Overview
An AI chess playing engine and interface for "melee" style chess where there is no player – it's every piece for itself!

There is also a training mode to gather best moves for feeding into Create ML.

Built using the following libraries and tools:

- [OctopusKit](https://github.com/InvadingOctopus/octopuskit)
- [SwiftChess](https://github.com/SteveBarnegren/SwiftChess)
- [Create ML](https://developer.apple.com/documentation/createml)

## Requirements
- macOS 11 (Big Sur)
- [Git LFS](https://git-lfs.github.com/)

## Installation
The ML models are quite large and [Git LFS](https://git-lfs.github.com/) is required to clone this repo.

**Install Git LFS (if needed)**
```shell
$ brew install git-lfs
$ git lfs install
```

Then you can clone the repo and the ML Models will be included.

## Configuration
Edit `Constants.swift`:
- Change `Constants.Chessboard.boardCount` for more or less boards horizontally
- Change `Constants.Chessboard.rowCount` for more or less ranks vertically

Have fun!

