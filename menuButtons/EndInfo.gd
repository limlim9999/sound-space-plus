extends Control

func comma_sep(number):
	var string = str(number)
	var mod = string.length() % 3
	var res = ""
	
	for i in range(0, string.length()):
		if i != 0 && i % 3 == mod:
			res += ","
		res += string[i]
	
	return res

func hide_info(_s=null):
	visible = false

func get_time_ms(ms:float):
	var s = max(floor(ms / 1000),0)
	var m = floor(s / 60)
	var rs = fmod(s,60)
	return "%d:%02d" % [m,rs]

func show_pb(_s=null):
	var pb = SSP.get_best()
	if pb:
		visible = true
		var misses = pb.total_notes - pb.hit_notes
		if pb.has_passed:
			$Result.text = "Personal Best"
			$Result.set("custom_colors/font_color",Color("#6ff1ff"))
		else:
			$Result.text = "Best Attempt"
			$Result.set("custom_colors/font_color",Color("#ea4aca"))
		
		$FullCombo.visible = misses == 0 && pb.has_passed
		$Misses.visible = !misses == 0 || !pb.has_passed
		$Misses.text = comma_sep(misses)
		
		$NoPauses.visible = pb.pauses == 0
		$Pauses.visible = !pb.pauses == 0
		$Pauses.text = comma_sep(pb.pauses)

		$Accuracy.text = "%s/%s\n%.03f%%" % [
			comma_sep(pb.hit_notes),
			comma_sep(pb.total_notes),
			(float(pb.hit_notes)/float(pb.total_notes))*100
		]
		$Progress.text = "%s\n%.2f%%" % [get_time_ms(pb.position),clamp(pb.position/SSP.selected_song.last_ms,0,1)*100]
	else:
		visible = true
		$Result.text = "No PB"
		$Result.set("custom_colors/font_color",Color("#ffdd99"))
		$FullCombo.visible = false
		$Misses.visible = true
		$Misses.text = "-"
		$NoPauses.visible = false
		$Pauses.visible = true
		$Pauses.text = "-"
		$Accuracy.text = "-\n"
		$Progress.text = "-\n"

func _ready():
	SSP.connect("selected_song_changed",self,"show_pb")
	SSP.connect("mods_changed",self,"show_pb")
	yield(SSP,"map_list_ready")
	if !SSP.selected_song: return
	$NewBest.stream = SSP.pb_snd
	if $NewBest.stream != SSP.normal_pb_sound:
		$NewBest.pitch_scale = 1
	visible = SSP.just_ended_song
	if SSP.just_ended_song:
		var is_best:bool = SSP.do_pb_check_and_set()
		if is_best: $NewBest.play()
		if SSP.song_end_type == Globals.END_PASS:
			if is_best: $Result.text = "New best!"
			else: $Result.text = "You passed!"
			$Result.set("custom_colors/font_color",Color("#6ff1ff"))
		elif is_best:
			$Result.text = "You failed (new best!)"
			$Result.set("custom_colors/font_color",Color("#ea4aca"))
		
		$FullCombo.visible = SSP.song_end_misses == 0 && SSP.song_end_type == Globals.END_PASS
		$Misses.visible = !SSP.song_end_misses == 0 || !SSP.song_end_type == Globals.END_PASS
		$Misses.text = comma_sep(SSP.song_end_misses)
		
		$NoPauses.visible = SSP.song_end_pause_count == 0
		$Pauses.visible = !SSP.song_end_pause_count == 0
		$Pauses.text = comma_sep(SSP.song_end_pause_count)

		$Accuracy.text = "%s/%s\n%.03f%%" % [
			comma_sep(SSP.song_end_hits),
			comma_sep(SSP.song_end_total_notes),
			(float(SSP.song_end_hits)/float(SSP.song_end_total_notes))*100
		]
		$Progress.text = "%s\n%.1f%%" % [SSP.song_end_time_str,clamp(SSP.song_end_position/SSP.song_end_length,0,1)*100]
	else:
		show_pb()