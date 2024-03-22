# Frequently Asked Questions, Comments, and Concerns

Here are questions, comments, and concerns that frequently come up.

## Frequently Asked Questions

### What is DragonRuby LLP?

DragonRuby LLP is a partnership of four devs who came together with the goal of bringing the aesthetics and joy of Ruby, everywhere possible.

Under DragonRuby LLP, we offer a number of products (with more on the way):

* Game Toolkit (GTK): A 2D game engine that is compatible with modern gaming platforms.
* RubyMotion (RM): A compiler toolchain that allows you to build native, cross-platform mobile apps. [http://rubymotion.com](http://rubymotion.com)
  
All of the products above leverage a shared core called DragonRuby.

!> NOTE: From an official branding standpoint each one of the products is suffixed with "A DragonRuby LLP Product" tagline. Also, DragonRuby is _one word, title cased_.

!> NOTE: We leave the "A DragonRuby LLP Product" off of this one because that just sounds really weird.

!> NOTE: Devs who use DragonRuby are "Dragon Riders/Riders of Dragons". That's a bad ass identifier huh?

### What is DragonRuby?

The response to this question requires a few subparts. First we need to clarify some terms. Specifically _language specification_ vs _runtime_.

**Okay... so what is the difference between a language specification and a runtime?**

A runtime is an _implementation_ of a language specification. When people say "Ruby," they are usually referring to "the Ruby 3.0+ language specification implemented via the CRuby/MRI Runtime."

But, there are many Ruby Runtimes: CRuby/MRI, JRuby, Truffle, Rubinius, Artichoke, and (last but certainly not least) DragonRuby.

**Okay... what language specification does DragonRuby use then?** 

DragonRuby's goal is to be compliant with the ISO/IEC 30170:2012 standard. It's syntax is Ruby 2.x compatible, but also contains semantic changes that help it natively interface with platform specific libraries.

**So... why another runtime?**

The elevator pitch is:

DragonRuby is a Multilevel Cross-platform Runtime. The "multiple levels" within the runtime allows us to target platforms no other Ruby can target: PC, Mac, Linux, Raspberry Pi, WASM, iOS, Android, Nintendo Switch, PS4, Xbox, and Stadia.

### What does Multilevel Cross-platform mean?

There are complexities associated with targeting all the platforms we support. Because of this, the runtime had to be architected in such a way that new platforms could be easily added (which lead to us partitioning the runtime internally):

* Level 1 we leverage a good portion of mRuby.
* Level 2 consists of optimizations to mRuby we've made given that our target platforms are well known.
* Level 3 consists of portable C libraries and their Ruby C-Extensions.

Levels 1 through 3 are fairly commonplace in many runtime implementations (with level 1 being the most portable, and level 3 being the fastest). But the DragonRuby Runtime has taken things a bit further:

* Level 4 consists of shared abstractions around hardware I/O and operating system resources. This level leverages open source and proprietary components within Simple DirectMedia Layer (a low level multimedia component library that has been in active development for 22 years and counting).
* Level 5 is a code generation layer which creates metadata that allows for native interoperability with host runtime libraries. It also includes OS specific message pump orchestrations.
* Level 6 is a Ahead of Time/Just in Time Ruby compiler built with LLVM. This compiler outputs _very_ fast platform specific bitcode, but only supports a subset of the Ruby language specification.

These levels allow us to stay up to date with open source implementations of Ruby; provide fast, native code execution on proprietary platforms; ensure good separation between these two worlds; and provides a means to add new platforms without going insane.

**Cool cool. So given that I understand everything to this point, can we answer the original question? What is DragonRuby?**

DragonRuby is a Ruby runtime implementation that takes all the lessons we've learned from MRI/CRuby, and merges it with the latest and greatest compiler and OSS technologies.

### How is DragonRuby different than MRI?

DragonRuby supports a subset of MRI apis. Our target is to support all of mRuby's standard lib. There are challenges to this given the number of platforms we are trying to support (specifically console).

### Does DragonRuby support Gems?

DragonRuby does not support gems because that requires the installation of MRI Ruby on the developer's machine (which is a non-starter given that we want DragonRuby to be a zero dependency runtime). While this seems easy for Mac and Linux, it is much harder on Windows and Raspberry Pi. mRuby has taken the approach of having a git repository for compatible gems and we will most likely follow suite: https://github.com/mruby/mgem-list.

### Does DragonRuby have a REPL/IRB?

You can use DragonRuby's Console within the game to inspect object and execute small pieces of code. For more complex pieces of code create a file called repl.rb and put it in mygame/app/repl.rb:

Any code you write in there will be executed when you change the file. You can organize different pieces of code using the repl method:

```ruby
repl do
  puts "hello world"
  puts 1 + 1
end
```

If you use the `repl` method, the code will be executed and the DragonRuby Console will automatically open so you can see the results (on Mac and Linux, the results will also be printed to the terminal).
All puts statements will also be saved to logs/puts.txt. So if you want to stay in your editor and not look at the terminal, or the DragonRuby Console, you can tail this file.
4. To ignore code in repl.rb, instead of commenting it out, prefix repl with the letter x and it'll be ignored.

```ruby
xrepl do # <------- line is prefixed with an "x"
  puts "hello world"
  puts 1 + 1
end

# This code will be executed when you save the file.
repl do
  puts "Hello"
end

repl do
  puts "This code will also be executed."
end

# use xrepl to "comment out" code
xrepl do
  puts "This code will not be executed because of the x in front of repl".
end
```

### Does DragonRuby support pry or have any other debugging facilities?

`pry` is a gem that assumes you are using the MRI Runtime (which is incompatible with DragonRuby). Eventually DragonRuby will have a pry based experience that is compatible with a debugging infrastructure called LLDB. Take the time to read about LLDB as it shows the challenges in creating something that is compatible.

You can use DragonRuby's replay capabilities to troubleshoot:

DragonRuby is hot loaded which gives you a very fast feedback loop (if the game throws an exception, it's because of the code you just added).
Use `./dragonruby mygame --record` to create a game play recording that you can use to find the exception (you can replay a recording by executing `./dragonruby mygame --replay last_replay.txt` or through the DragonRuby Console using `$gtk.recording.start_replay "last_replay.txt"`.

DragonRuby also ships with a unit testing facility. You can invoke the following command to run a test: `./dragonruby mygame --test tests/some_ruby_file.rb`.
Get into the habit of adding debugging facilities within the game itself. You can add drawing primitives to `args.outputs.debug` that will render on top of your game but will be ignored in a production release.

Debugging something that runs at 60fps is (imo) not that helpful. The exception you are seeing could have been because of a change that occurred many frames ago.


## Frequent Comments About Ruby as a Language Choice

### But Ruby is dead.

Let's check the official source for the answer to this question: [isrubydead.com](https://isrubydead.com/).

On a more serious note, Ruby's _quantity_ levels aren't what they used to be. And that's totally fine. Everyone chases the new and shiny.

What really matters is _quality/maturity_. Here's a StackOverflow Survey sorted by highest paid developers: https://insights.stackoverflow.com/survey/2021#section-top-paying-technologies-top-paying-technologies.

Let's stop making this comment shall we?

### But Ruby is slow.

That doesn't make any sense. A language specification can't be slow... it's a language spec. Sure, an _implementation/runtime_ can be slow though, but then we'd have to talk about which runtime.

Here are some quick demonstrations of how well DragonRuby Game Toolkit Performs:

DragonRuby vs Unity: https://youtu.be/MFR-dvsllA4
DragonRuby vs PyGame: https://youtu.be/fuRGs6j6fPQ

### Dynamic languages are slow.

They are certainly slower than statically compiled languages. With the processing power and compiler optimizations we have today, dynamic languages like Ruby are _fast enough_.

Unless you are writing in some form of intermediate representation by hand, your language of choice also suffers this same fallacy of slow. Like, nothing is faster than a low level assembly-like language. So unless you're writing in that, let's stop making this comment.

!> NOTE: If you _are_ hand writing LLVM IR, we are always open to bringing on new partners with such a skill set. Email us ^_^.

## Frequent Concerns

### DragonRuby is not open source. That's not right.

The current state of open source is unsustainable. Contributors work for free, most all open source repositories are severely under-staffed, and burnout from core members is rampant.

We believe in open source very strongly. Parts of DragonRuby are in fact, open source. Just not all of it (for legal reasons, and because the IP we've created has value). And we promise that we are looking for (or creating) ways to _sustainably_ open source everything we do.

If you have ideas on how we can do this, email us!

If the reason above isn't sufficient, then definitely use something else.

All this being said, we do have parts of the engine open sourced on GitHub: https://github.com/dragonruby/dragonruby-game-toolkit-contrib/

### DragonRuby is for pay. You should offer a free version.

If you can afford to pay for DragonRuby, you should (and will). We don't tell authors that they should give us their books for free, and only require payment if we read the entire thing. It's time we stop asking that of software products.

That being said, we will _never_ put someone out financially. We have income assistance for anyone that can't afford a license to any one of our products.

You qualify for a free, unrestricted license to DragonRuby products if any of the following items pertain to you:

* Your income is below $2,000.00 (USD) per month.
* You are under 18 years of age.
* You are a student of any type: traditional public school, home schooling, college, bootcamp, or online.
* You are a teacher, mentor, or parent who wants to teach a kid how to code.
* You work/worked in public service or at a charitable organization: for example public office, army, or any 501(c)(3) organization.

Just contact Amir at amir.rajan@dragonruby.org with a short explanation of your current situation and he'll set you up. No questions asked.

**But still, you should offer a free version. So I can try it out and see if I like it.**

You can try our web-based sandbox environment at http://fiddle.dragonruby.org. But it won't do the runtime justice. Or just come to our Discord Channel at http://discord.dragonruby.org and ask questions. We'd be happy to have a one on one video chat with you and show off all the cool stuff we're doing.

Seriously just buy it. Get a refund if you don't like it. We make it stupid easy to do so.

**I still think you should do a free version. Think of all people who would give it a shot.**

Free isn't a sustainable financial model. We don't want to spam your email. We don't want to collect usage data off of you either. We just want to provide quality toolchains to quality developers (as opposed to a large quantity of developers).

The people that pay for DragonRuby and make an effort to understand it are the ones we want to build a community around, partner with, and collaborate with. So having that small monetary wall deters entitled individuals that don't value the same things we do.

### What if I build something with DragonRuby, but DragonRuby LLP becomes insolvent.

We want to be able to work on the stuff we love, every day of our lives. And we'll go to great lengths to make that continues.

But, in the event that sad day comes, our partnership bylaws state that _all_ DragonRuby IP that can be legally open sourced, will be released under a permissive license.

