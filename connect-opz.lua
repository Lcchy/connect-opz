-- Toggle OP-Z as USB
-- audio device on norns.
--
--
--
-- K2: toggle input from OP-Z.
-- K3: toggle output to OP-Z.

opz_connected = nil
opz_input = nil
opz_output = nil

t = 0

function init()
  opz_connected = opz_is_connected()
  opz_input = opz_input_is_setup()
  opz_output = opz_output_is_setup()
  counter = metro.init(tick, 1, -1)
  counter:start()
  redraw()
end

function tick(tock)
  t = tock
  opz_connected = opz_is_connected()
  opz_input = opz_input_is_setup()
  opz_output = opz_output_is_setup()
  redraw()
end

function redraw()
  screen.clear()

  if opz_connected and (opz_input or opz_output) then draw_dancing_music() end
  draw_status_graphics()
  draw_status_text()

  screen.stroke()
  screen.update()
end

function key(n, z)
  opz_connected = opz_is_connected()
  opz_input = opz_input_is_setup()
  opz_output = opz_output_is_setup()
  
  if n == 2 and z == 1 then
    print("Toggling input")
    toggle_audio_input()
  end
  if n == 3 and z == 1 then
    print("Toggling output")
    toggle_audio_output()
  end
  redraw()
end

function opz_is_connected()
  opz_connected = os.execute('lsusb -d 2367:000c') or false
  return opz_connected
end

function opz_input_is_setup()
   opz_setup = os.execute('pidof alsa_in') or false
   return opz_setup
end

function opz_output_is_setup()
   opz_output = os.execute('pidof alsa_out') or false
   return opz_output
end

function toggle_audio_input()
  if opz_is_connected() then
    if not opz_input_is_setup() then
      print("Setting up audio input")
      os.execute(_path.this.lib..'connect-opz-input.sh')
    else
      print("Tearing down audio input")
      os.execute(_path.this.lib..'disconnect-opz-input.sh')
    end
  else
    print("It's not connected")
    opz_connected = false
    -- just to maintain sane state.
    os.execute(_path.this.lib..'connect-opz-input.sh')
  end
  opz_input = opz_input_is_setup()
end

function toggle_audio_output()
  if opz_is_connected() then
    if not opz_output_is_setup() then
      print("Setting up audio output")
      os.execute(_path.this.lib..'connect-opz-output.sh')
    else
      print("Tearing down audio output")
      os.execute(_path.this.lib..'disconnect-opz-output.sh')
    end
  else
    print("It's not connected")
    opz_connected = false
    -- just to maintain sane state.
    os.execute(_path.this.lib..'connect-opz-output.sh')
  end
  opz_output = opz_output_is_setup()
end

function draw_dancing_music()
  for i=0,bool_to_number(opz_input)+bool_to_number(opz_output) do
    screen.move(math.random(0, 124), math.random(0, 60))
    screen.font_size(math.random(5, 20))
    screen.level(1)
    screen.text("♫")
  end
  screen.stroke()
end

function draw_status_graphics()
  local x_pos = 60
  local dial_r = 5
  for i=1,4 do
    -- dial edges
    screen.level(1 + 3*bool_to_number(opz_connected))
    screen.circle(x_pos + 15*i, 10, dial_r + 2)
    screen.stroke()
    
    -- dial discs
    screen.level(1 + 6*bool_to_number(opz_input) + 6*bool_to_number(opz_output))
    screen.circle(x_pos + 15*i, 10, dial_r)
    screen.fill()
    
    -- dial centres
    screen.level(0)
    screen.circle(x_pos + 15*i, 10, dial_r - 3)
    screen.fill()
    
    -- dial lines
    if opz_input or opz_output then
      screen.move(x_pos + 15*i, 10)
      screen.move_rel((-math.cos(t/i%10) * dial_r), -math.sin(t/i%10) * dial_r)
      screen.line(x_pos + 15*i, 10)
      screen.move_rel(math.cos(t/i%10) * dial_r, math.sin(t/i%10) * dial_r)
      screen.line(x_pos + 15*i, 10)
      screen.stroke()
    else
      screen.move(x_pos + 15*i, 10)
      screen.move_rel(-dial_r, 0)
      screen.line_rel(dial_r * 2, 0)
      screen.stroke()
    end
  end
end

function draw_status_text()
  screen.level(15)
  screen.move(55, 40)
  screen.font_size(8)
  screen.text_right("connected:")
  screen.text(tostring(opz_connected))
  
  screen.move(55, 40 + 7)
  screen.text_right("audio input:")
  screen.text(tostring(opz_input))

  screen.move(55, 40 + 7*2)
  screen.text_right("audio output:")
  screen.text(tostring(opz_output))
end

function bool_to_number(value)
  return value == true and 1 or value == false and 0
end
