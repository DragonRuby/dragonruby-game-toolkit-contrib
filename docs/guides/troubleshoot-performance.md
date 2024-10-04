# Troubleshoot Performance

- Avoid deep recursive calls.
- If you're using `Arrays` for your primitives (`args.outputs.sprites
  << []`), use `Hash` instead (`args.outputs.sprites << { x: ... }`). 
- Use `.each` instead of `.map` if you don't care about the return value.
- When concatenating primitives to outputs, do them in bulk.

  Instead of:
  
  ```ruby
  args.state.bullets.each do |bullet|
    args.outputs.sprites << bullet.sprite
  end
  ```
  
  do
  
  ```ruby
  args.outputs.sprites << args.state.bullets.map do |b|
    b.sprite
  end
  ```

- Use `args.outputs.static_` variant for things that don't change
  often (take a look at the Basic Gorillas sample app and Dueling
  Starships sample app to see how `static_` is leveraged. 
- Consider using a `render_target` if you're doing some form of a
  camera that moves a lot of primitives (take a look at the Render
  Target sample apps for more info). 
- Avoid deleting or adding to an array during iteration. Instead of:

  ```ruby
  args.state.bullets.each do |bullet|
    args.state.fx_queue.each |fx|
      fx.count_down ||= 255
      fx.countdown -= 5
      if fx.countdown < 0
        args.state.fx_queue.delete fx
      end
    end
  end
  ```
  
  Do:
  
  ```ruby
  args.state.bullets.each do |bullet|
    args.state.fx_queue.each |fx|
      fx.countdown ||= 255
      fx.countdown -= 5
    end
  end
  
  args.state.fx_queue.reject! { |fx| fx.countdown < 0 }
  ```
