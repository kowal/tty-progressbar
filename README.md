# TTY::ProgressBar [![Gitter](https://badges.gitter.im/Join%20Chat.svg)][gitter]
[![Gem Version](https://badge.fury.io/rb/tty-progressbar.svg)][gem]
[![Build Status](https://secure.travis-ci.org/piotrmurach/tty-progressbar.svg?branch=master)][travis]
[![Build status](https://ci.appveyor.com/api/projects/status/w3jafjeatt1ulufa?svg=true)][appveyor]
[![Code Climate](https://codeclimate.com/github/piotrmurach/tty-progressbar/badges/gpa.svg)][codeclimate]
[![Coverage Status](https://coveralls.io/repos/github/piotrmurach/tty-progressbar/badge.svg)][coverage]
[![Inline docs](http://inch-ci.org/github/piotrmurach/tty-progressbar.svg?branch=master)][inchpages]

[gitter]: https://gitter.im/piotrmurach/tty
[gem]: http://badge.fury.io/rb/tty-progressbar
[travis]: http://travis-ci.org/piotrmurach/tty-progressbar
[appveyor]: https://ci.appveyor.com/project/piotrmurach/tty-progressbar
[codeclimate]: https://codeclimate.com/github/piotrmurach/tty-progressbar
[coverage]: https://coveralls.io/github/piotrmurach/tty-progressbar
[inchpages]: http://inch-ci.org/github/piotrmurach/tty-progressbar

> A flexible progress bars drawing in terminal emulators.

**TTY::ProgressBar** provides independent progress bars component for [TTY](https://github.com/piotrmurach/tty) toolkit.

## Features

* Fully [configurable](#3-configuration)
* Extremely flexible progress display [formatting](#4-formatting)
* Includes many predefined tokens to calculate ETA, Bytes ... [tokens](#41-tokens)
* Allows to define your [custom tokens](#42-custom-formatters)
* Supports parallel multi progress bars [multi](#6-ttyprogressbarmulti-api)
* Works on all ECMA-48 compatible terminals

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'tty-progressbar'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install tty-progressbar

## Contents

* [1. Usage](#1-usage)
* [2. TTY::ProgressBar::API](#2-ttyprogressbar-api)
  * [2.1 advance](#21-advance)
  * [2.2 current=](#22-current)
  * [2.3 ratio=](#23-ratio)
  * [2.4 width=](#24-width)
  * [2.5 start](#25-start)
  * [2.6 update](#26-update)
  * [2.7 finish](#27-finish)
  * [2.8 stop](#28-stop)
  * [2.9 reset](#29-reset)
  * [2.10 complete?](#210-complete)
  * [2.11 resize](#211-resize)
  * [2.12 on](#212-on)
* [3. Configuration](#3-configuration)
  * [3.1 :head](#31-head)
  * [3.2 :frequency](#32-interval)
  * [3.3 :interval](#33-interval)
* [4. Formatting](#4-formatting)
  * [4.1 Tokens](#41-tokens)
  * [4.2 Custom Formatters](#42-custom-formatters)
  * [4.3 Custom Tokens](#43-custom-tokens)
* [5. Logging](#5-logging)
* [6. TTY::ProgressBar::Multi](#6-ttyprogressbarmulti-api)
  * [6.1 register](#61-register)
* [7. Examples](#7-examples)
  * [7.1 Color](#71-color)

## 1. Usage

**TTY::ProgressBar** requires only format string and total number of steps to completion. Once initialized, use `advance` method to indicated the progress like so:

```ruby
bar = TTY::ProgressBar.new("downloading [:bar]", total: 30)
30.times do
  sleep(0.1)
  bar.advance(1)
end
```

This would produce animation in your terminal:

```ruby
# downloading [=======================       ]
```

## 2. TTY::ProgressBar API

### 2.1 advance

Once you have **TTY::ProgressBar** instance, you can progress the display by calling `advance` method. By default it will increase by `1` but you can pass any number of steps, for instance, when used to advance number of bytes of downloaded file.

```ruby
bar.advance(1000)
```

You can also pass negative steps if you wish to backtrack the progress:

```ruby
bar.advance(-1)
```

Note: If a progress bar has already finished then negative steps will not set it back to desired value.

### 2.2 current=

**TTY::ProgressBar** allows you to set progress to a given value by calling `current=` method.

```ruby
bar.current = 50
```

Note: If a progress bar has already finished then negative steps will not set it back to desired value.

### 2.3 ratio=

In order to update overall completion of a progress bar as an exact percentage use the `ratio=` method. The method accepts values between `0` and `1` inclusive. For example, a ratio of 0.5 will attempt to set the progress bar halfway:

```ruby
bar.ratio = 0.5
```

### 2.4 width=

You can set how many terminal columns will the `:bar` actually span excluding any other tokens and/or text. For example if you need the bar to be always 20 columns wwide do:

```ruby
bar.width = 20
```

or with configuration options:

```ruby
bar = TTY::ProgressBar.new("[:bar]", width: 20)
```

### 2.5 start

By default the timer for internal time esitamation is started automatically when the `advance` method is called. However, if you require control on when the progression timer is started use `start` call:

```ruby
bar.start  # => sets timer and draws initial progress bar
```

### 2.6 update

Once the progress bar has been started you can change its configuration option(s) by calling `update`:

```ruby
bar.update(complete: '+', frequency: 10)
```

### 2.7 finish

In order to immediately stop and finish the progress call `finish`. This will finish drawing the progress and return to new line.

```ruby
bar.finish
```

### 2.8 stop

In order to immediately stop the bar in the current position and thus finish any further progress use `stop`:

```ruby
bar.stop
```

### 2.9 reset

In order to reset currently running or finished progress bar to its original configuration and initial position use `reset` like so:

```ruby
bar.reset
```

After resetting the bar if you wish to draw and start the bar and its timers use `start` call.

### 2.10 complete?

During progresion you can check if a bar is finished or not by calling `complete?`. The bar will only return `true` if the progression finished successfuly, otherwise `false` will be returned.

```ruby
bar.complete? # => false
```

### 2.11 resize

If you wish for a progress bar to change it's current width, you can use `resize` by passing in a new desired length. However, if you don't provide any width the `resize` will use terminal current width as its base for scaling.

```ruby
bar.resize      # => determine terminal width and scale accordingly
bar.resize(50)  # => will resize bar proportionately from this point onwards
```

To handle automatic resizing you can trap `:WINCH` signal:

```ruby
trap(:WINCH) { bar.resize }
```

### 2.12 on

The progress bar fires events when it is stopped or finished. You can register to listen for events using the `on` message.

When the progress bar finishes and completes then the `:done` event is fired. You can listen for this event:

```ruby
bar.on(:done) { ... }
```

Alternatively, when the progress bar gets stopped the `:stopped` event is fired. You can listen for this event:

```ruby
bar.on(:stopped) { ... }
```

## 3. Configuration

There are number of configuration options that can be provided:

* `:total` total number of steps to completion
* `:width` of the bars display in terminal columns excluding formatting options. Defaults to total steps
* `:complete` completion character by default `=`
* `:incomplete` incomplete character by default single space
* [:head](#21-head) the head character by default `=`
* `:output` the output stream defaulting to `stderr`
* [:frequency](#22-frequency) used to throttle the output, by default `0`
* [:interval](#23-interval) used to measure the speed, by default `1 sec`
* `:hide_cursor` to hide display cursor defaulting to `false`
* `:clear` to clear the finished bar defaulting to `false`

All the above options can be passed in as hash options or block parameters:

```ruby
TTY::ProgressBar.new "[:bar]" do |config|
  config.total = 30
  config.frequency = 10
  config.clear = true
end
```

### 3.1 :head

If you prefer for the animated bar to display a specific character for a head of progression then use `:head` option:

```ruby
bar = TTY::ProressBar.new("[:bar]", head: '>')
#
# [=======>      ]
```

### 3.2 :frequency

Each time the `advance` is called it causes the progress bar to repaint. In cases when there is a huge number of updates per second, you may need to limit the rendering process by using the `frequency` option.

The `frequency` option accepts `integer` representing number of `Hz` units, for instance, frequency of 2 will mean that the progress will be updated maximum 2 times per second.

```ruby
TTY::ProgressBar.new("[:bar]", total: 30, frequency: 10) # 10 Hz
```

### 3.3 :interval

For every call of `advance` method the **ProgressBar** takes a sample for speed measurement. By default the samples are grouped per second but you can change that by passing the `interval` option.

The `interval` option is an `integer` that represents the number of seconds, for example, interval of `60` would mean that speed is measured per 1 minute.

```ruby
TTY::ProgressBar.new(":rate/minute", total: 100, interval: 60) # 1 minute

TTY::ProgressBar.new(":rate/hour", total: 100, interval: 3600) # 1 hour
```

## 4. Formatting

Every **TTY::ProgressBar** instance requires a format string, which apart from regular characters accepts special tokens to display dynamic information. For instance, a format to measure download progress could be:

```ruby
"downloading [:bar] :elapsed :percent"
```

### 4.1 Tokens

These are the tokens that are currently supported:

* `:bar` the progress bar
* `:current` the current progress number
* `:current_byte` the current progress in bytes
* `:total` the total progress number
* `:total_byte` the total progress in bytes
* `:percent` the completion percentage
* `:elapsed` the elapsed time in seconds
* `:eta` the esitmated time to completion in seconds
* `:rate` the current rate of progression per second
* `:byte_rate` the current rate of pregression in bytes per second
* `:mean_rate` the averaged rate of progression per second
* `:mean_byte` the averaged rate of progression in bytes per second

### 4.2 Custom Formatters

If the provided tokens do not meet your needs, you can write your own formatter and instrument formatting pipeline to use a formatter you prefer. This option is preferred if you are going to rely on progress bar internal data such as `rate`, `current` etc. which will all be available on the passed in progress bar instance.

For example, begin by creating custom formatter called `TimeFormatter` that will dynamicly update `:time` token in format string. The methods that you need to specify are `initialize`, `matches?` and `format` like follows:

```ruby
class TimeFormatter
  def initialize(progress)
    @progress = progress # current progress bar instance
  end

  def matches?(value)  # specify condition to match for in display string
    value.to_s =~ /:time/
  end

  def format(value)  # specify how display string is formatted
    transformed = (Time.now - @progress.start_at).to_s
    value.gsub(/:time/, transformed)   # => :time token replacement
  end
end
```

Notice that you have access to all the configuration options inside the formatter by simply invoking them on the `@progress` instance.

Create **TTY::ProgressBar** instance with new token:

```ruby
bar = TTY::ProgressBar.new(":time", total: 30)
```

Then add `TimeFormatter` to the pipeline like so:

```ruby
bar.use TimeFormatter
```

and then invoke progression:

```ruby
bar.advance
```

### 4.3 Custom Tokens

You can define custom tokens by passing pairs `name: value` to `advance` method in order to dynamically update formatted bar. This option is useful for lightweight content replacement such as titles that doesn't depend on the internal data of progressbar. For example:

```ruby
bar = TTY::ProgressBar.new("(:current) :title", total: 4)
bar.advance(title: 'Hello Piotr!')
bar.advance(3, title: 'Bye Piotr!')
```

which outputs:

```ruby
(1) Hello Piotr!
(4) Bye Piotr!
```

## 5. Logging

If you want to print messages out to terminal along with the progress bar use the `log` method. The messages will appear above the progress bar and will continue scrolling up as more are logged out.

```ruby
bar.log('Piotrrrrr')
bar.advance
```

will result in:

```ruby
Piotrrrrr
downloading [=======================       ]
```

## 6. TTY::ProgressBar::Multi API

### 6.1 register

To create a `TTY::ProgressBar` under the multibar use `register` like so:

```ruby
multibar = TTY::ProgressBar::Multi.new
multibar.register("[:bar]", total: 30)
```

## 7. Examples

This section demonstrates some of the possible uses for the **TTY::ProgressBar**, for more please see examples folder in the source directory.

### 7.1 Colors

Creating a progress bar that displays in color is as simple as coloring the `:complete` and `:incomplete` character options. In order to help with coloring you can use [pastel](https://github.com/piotrmurach/pastel) library like so:

```ruby
require 'pastel'

pastel = Pastel.new
green  = pastel.on_green(" ")
red    = pastel.on_red(" ")
```

And then pass in the colored strings as options to **TTY::ProgressBar**:

```ruby
bar = TTY::ProgressBar.new("|:bar|",
  total: 30,
  complete: green,
  incomplete: red
)
```

To see how a progress bar is reported in terminal you can do:

```ruby
30.times do
  sleep(0.1)
  bar.advance
end
```

### 5.2 Speed

Commonly a progress bar is utilized to measure download speed per second. This can be done like so:

```ruby
TTY::ProgressBar.new("[:bar] :byte_rate/s") do |config|
  config.total = 300000
  config.interval = 1     # => 1 sec
end
```

This will result in output similar to:

```ruby
downloading [=======================       ] 4.12MB/s
```

## Contributing

1. Fork it ( https://github.com/piotrmurach/tty-progressbar/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Copyright

Copyright (c) 2014-2017 Piotr Murach. See LICENSE for further details.
