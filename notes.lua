-- This hold length data makes the bodies look a bit screwy, but at least the
-- cap doesn't stick past the note.
local cap_len= .125
local hold_len_data= {
   start_note_offset= -cap_len, end_note_offset= cap_len,
   head_pixs= 3, body_pixs= 9, tail_pixs= 3}
local function generic_hold(anim_frames)
   return {
      state_map= NoteSkin.single_quanta_state_map(anim_frames),
      textures= {"hold_bodies"},
      flip= "TexCoordFlipMode_None",
      length_data= hold_len_data,
      disable_filtering= true,
   }
end
local column_width= 64
local function zoom_tap(self)
   self:zoom(column_width / 11):SetTextureFiltering(false)
end
return function(button_list)
   -- I was going to make this support tons of quantizations for humor, but
   -- 12ths came out the wrong color.   I'm guessing 720720 parts_per_beat
   -- goes over a precision limit or similar.
   --   local tap_states= gen_state_map(4, {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16})

   local tap_states= NoteSkin.generic_state_map(5, {1, 2, 3, 4, 6, 8, 12, 16, 24, 32})
   local mine_states= NoteSkin.generic_state_map(4, {1, 2, 3, 4, 6, 8, 12, 16, 24, 32})

   local no_quanta_tap_states= NoteSkin.generic_state_map(5, {1})
   local no_quanta_mine_states= NoteSkin.generic_state_map(4, {1})

   local columns= {}
   local holds= {
      TapNoteSubType_Hold= {
         generic_hold{1},
         generic_hold{2, 3, 4, 5},
      },
      TapNoteSubType_Roll= {
         generic_hold{6},
         generic_hold{7, 8, 9, 10},
      },
      --[[
         TapNoteSubType_Checkpoint= {
         generic_hold{11},
         generic_hold{12, 13, 14, 15},
         },
      ]]
   }
   for i, button in ipairs(button_list) do
	  -- Toggle this to move which side the record is on
	  record_on_right = true
	  
	  local beat_note_texture = "tap_note"
	  local tap_state_map = tap_states
	  local note_width = 64
	  local custom_x = nil
	  if i == 1 then
		 tap_state_map = no_quanta_tap_states
		 beat_note_texture = "record_tap_note"
		 if record_on_right then
			custom_x = note_width * 4
		 end
	  elseif i % 2 == 0 then
		 beat_note_texture = "tap_note"
	  else
		 beat_note_texture = "black_tap_note"
	  end
	  
	  columns[i]= {
		 width= note_width, padding= 0,
		 anim_time= 1, anim_uses_beats= true,
		 custom_x= custom_x,
		 taps= {
			NoteSkinTapPart_Tap= {
			   state_map= tap_state_map, --tap_states,
			   actor= Def.Sprite{Texture= beat_note_texture, InitCommand= zoom_tap}},
			NoteSkinTapPart_Mine= {
			   state_map= mine_states,
			   actor= Def.Sprite{Texture= "mine_note", InitCommand= zoom_tap}},
			NoteSkinTapPart_Lift= {
			   state_map= tap_state_map, --tap_states,
			   actor= Def.Sprite{Texture= "lift_note", InitCommand= zoom_tap}},
		 },
		 holds= holds,
		 reverse_holds= holds,
	  }
	  
   end
   return {columns= columns, vivid_operation= true}
end
