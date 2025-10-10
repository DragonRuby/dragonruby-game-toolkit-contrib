class Game
  attr_gtk

  def initialize
    @ingredients_in_hand = []
    @available_ingredients = [
      :flour,
      :baking_soda,
      :sugar,
      :flour,
      :baking_soda,
      :sugar
    ]
  end

  def tick
    calc
    render
  end

  def ingredient_selection_prefabs
    @available_ingredients.map.with_index do |ingredient, index|
      ingredient_selection_prefab(
        id: ingredient,
        index: index)
    end
  end

  def ingredients_in_hand_prefabs
    @ingredients_in_hand.map.with_index do |ingredient, index|
      render_box = Layout.rect(col: 11, row: 4 - index, w: 2, h: 2)
      {
        id: ingredient,
        index: index,
        render_box: render_box,
        primitives: [
          render_box.merge(path: "sprites/square/green.png", a: 128),
          render_box.center.merge(text: ingredient.to_s.split('_').map(&:capitalize).join(' '),
                                  anchor_x: 0.5,
                                  anchor_y: 0.5)
        ]
      }
    end
  end

  def cook_ingredients_in_hand_prefab
    render_box = Layout.rect(col: 10, row: 7, w: 4, h: 2)
    {
      id: :cook_ingredients_in_hand,
      render_box: render_box,
      primitives: [
        render_box.merge(path: :solid, r: 255, g: 255, b: 255),
        render_box.center.merge(text: "Cook Ingredients", anchor_x: 0.5, anchor_y: 0.5)
      ]
    }
  end

  def calc
    select_ingredient!
    cook_ingredients_in_hand!
  end

  def select_ingredient!
    @hovered_ingredient_selection = ingredient_selection_prefabs.find { |i| Geometry.intersect_rect? inputs.mouse, i.render_box }

    if inputs.mouse.click && @hovered_ingredient_selection
      @available_ingredients.delete_at @hovered_ingredient_selection.index
      @ingredients_in_hand << @hovered_ingredient_selection.id
    end
  end

  def cook_ingredients_in_hand!
    return if !inputs.mouse.click
    return if !Geometry.intersect_rect?(inputs.mouse, cook_ingredients_in_hand_prefab.render_box)

    if @ingredients_in_hand.include?(:flour) &&
       @ingredients_in_hand.include?(:baking_soda) &&
       @ingredients_in_hand.include?(:sugar) &&
       @ingredients_in_hand.length == 3
      @ingredients_in_hand.clear
      @available_ingredients.push_back(:cake)
    else
      @ingredients_in_hand.clear
      @available_ingredients.push_back(:poop)
    end
  end

  def render
    outputs.sprites << { x: 640, y: 360, w: 80, h: 80, path: "sprites/square/blue.png", anchor_x: 0.5, anchor_y: 0.5 }
    render_ingredient_selection
    outputs.primitives << ingredients_in_hand_prefabs.map { |i| i.primitives }
    outputs.primitives << cook_ingredients_in_hand_prefab.primitives
  end

  def render_ingredient_selection
    if @hovered_ingredient_selection
      outputs.primitives << @hovered_ingredient_selection.render_box.merge(path: :solid, r: 255, g: 0, b: 0, a: 128)
    end
    outputs.primitives << ingredient_selection_prefabs.map { |i| i.primitives }
  end

  def ingredient_selection_prefab(id: , index:)
    text = id.to_s
             .split('_')
             .map(&:capitalize)
             .join(' ')

    render_box = Layout.rect(col: 22, row: index * 2, w: 2, h: 2)

    {
      id: id,
      index: index,
      render_box: render_box,
      primitives: [
        render_box.merge(path: "sprites/square/green.png", a: 128),
        render_box.center.merge(text: text, anchor_x: 0.5, anchor_y: 0.5)
      ]
    }
  end
end

def boot args
  args.state = {}
end

def tick args
  $game ||= Game.new
  $game.args = args
  $game.tick
end

def reset args
  $game = nil
end

GTK.reset
