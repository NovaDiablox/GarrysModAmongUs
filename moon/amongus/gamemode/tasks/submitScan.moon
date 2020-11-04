taskTable = {
	Init: =>
		@Base.Init @

		if SERVER
			@SetNetworkable "CompletionTime"

	Type: GM.TaskType.Long
	Time: 10
	CanUse: => not IsValid(@GetActivationButton!\GetNW2Entity "Scanning") and
		30 > @GetAssignedPlayer!.entity\GetPos!\Distance @GetActivationButton!\GetPos!
	
	Advance: (btn, scan) =>
		if scan
			btn\SetNW2Entity "Scanning", nil
			@SetCompleted true

	OnUse: (btn) =>
		@Base.OnUse @, btn

		if not IsValid btn\GetNW2Entity "Scanning"
			btn\SetNW2Entity "Scanning", @GetAssignedPlayer!.entity
			btn\SetNW2Float "Completion", CurTime! + @Time

			handle = "medbay #{@GetID!}"
			GAMEMODE.GameData.Timers[handle]
			timer.Create handle, @Time, 1, ->
				if IsValid(btn) and IsValid(@GetAssignedPlayer!.entity) and
					@GetAssignedPlayer!.entity == btn\GetNW2Entity "Scanning"
						@Advance btn, true
	
	OnCancel: (btn) =>
		if @GetAssignedPlayer!.entity == btn\GetNW2Entity "Scanning"
			btn\SetNW2Entity "Scanning", nil
}

if CLIENT
	taskTable.CreateVGUI = =>
		base = vgui.Create "AmongUsTaskBase"

		with base
			\Setup with vgui.Create "DPanel"
				max_size = ScrH! * 0.7

				\SetSize max_size, max_size * 0.2

				\SetBackgroundColor Color 64, 64, 64
				with \Add "DLabel"
					\SetFont "NMW AU PlaceholderText"
					\SetColor Color 255, 255, 255
					\SetContentAlignment 5
					\SetText "..."
					\Dock FILL
					\SizeToContents!

					submitted = false
					.Think = ->
						time = @GetActivationButton!\GetNW2Float("Completion") or (CurTime! + @Time)
						\SetText string.format "We scanning boiz, %d s.", math.max 0, time - CurTime!
						if (time - CurTime!) < 0 and not submitted
							submitted = true
							base\Submit!					

			\Popup!

return taskTable
