
def subscribe(modifiers, key)
	Windawesome::ShortcutsManager.subscribe modifiers, key, lambda {
		ret = yield
		return true if ret == nil
		ret
	}
end

flashing_window = nil

def get_managed_window workspace, hWnd
	Windawesome::Windawesome.do_for_self_and_owners_while hWnd, lambda { |h| not workspace.contains_window h }
end

def get_current_workspace_managed_window
	get_managed_window windawesome.current_workspace, Windawesome::NativeMethods.get_foreground_window
end

Windawesome::Windawesome.window_flashing do |l|
	flashing_window = l.first.value.item2.hWnd
end

modifiers = Windawesome::ShortcutsManager::KeyModifiers
key = System::Windows::Forms::Keys

# quit Windawesome
subscribe modifiers.Alt | modifiers.Shift, key.Q do
	windawesome.quit
end

# refresh Windawesome
subscribe modifiers.Alt | modifiers.Shift, key.R do
	windawesome.refresh_windawesome
end

# quit application
subscribe modifiers.Alt, key.Q do
	windawesome.quit_application Windawesome::NativeMethods.get_foreground_window
end

subscribe modifiers.Control | modifiers.Alt | modifiers.Shift, key.Q do
	windawesome.remove_application_from_workspace get_current_workspace_managed_window
end

# dismiss application
subscribe modifiers.Alt, key.D do
	windawesome.dismiss_temporarily_shown_window Windawesome::NativeMethods.get_foreground_window
end

# minimize application
subscribe modifiers.Alt, key.A do
	windawesome.minimize_application Windawesome::NativeMethods.get_foreground_window
end

# maximize or restore application
subscribe modifiers.Alt, key.S do
	window = Windawesome::NativeMethods.get_foreground_window
	ws = Windawesome::NativeMethods.get_window_style_long_ptr.invoke window
	if ws.has_flag Windawesome::NativeMethods::WS.WS_MAXIMIZE
		windawesome.restore_application window
	elsif ws.has_flag Windawesome::NativeMethods::WS.WS_CAPTION and ws.has_flag Windawesome::NativeMethods::WS.WS_MAXIMIZEBOX
		windawesome.maximize_application window
	end
end

# switch to previous workspace
subscribe modifiers.Alt, key.Oemtilde do
	windawesome.switch_to_workspace windawesome.previous_workspace.id
end

# start Firefox
subscribe modifiers.Alt, key.F do
	windawesome.run_or_show_application "^MozillaWindowClass$", "C:\\Program Files (x86)\\Mozilla Firefox\\firefox.exe"
end

# start Explorer
subscribe modifiers.Alt, key.E do
	windawesome.run_application "C:\\Users\\Boris\\Desktop\\Downloads.lnk"
end

# start Hostile Takeover
subscribe modifiers.Alt, key.H do
	windawesome.run_application "C:\\Users\\Boris\\Downloads\\Hostile Takeover.txt"
end

# start Foobar2000
subscribe modifiers.Alt, key.W do
	windawesome.run_application "C:\\Program Files (x86)\\foobar2000\\foobar2000.exe"
end

# start Cygwin's MinTTY shell
subscribe modifiers.Alt | modifiers.Shift, key.Return do
	windawesome.run_application "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Programs\\Cygwin\\mintty.lnk"
end

# start Bitcomet
subscribe modifiers.Alt, key.B do
	windawesome.run_application "C:\\Program Files\\BitComet\\BitComet.exe"
end

# switch to flashing window
subscribe modifiers.Alt, key.U do
	windawesome.switch_to_application flashing_window if flashing_window
end

# toggle window floating
subscribe modifiers.Control | modifiers.Alt | modifiers.Shift, key.F do
	windawesome.toggle_window_floating get_current_workspace_managed_window
end

# toggle window titlebar
subscribe modifiers.Alt | modifiers.Shift, key.D do
	windawesome.toggle_show_hide_window_titlebar Windawesome::NativeMethods.get_foreground_window
end

# toggle Windows taskbar
subscribe modifiers.Alt | modifiers.Control, key.Space do
	windawesome.toggle_taskbar_visibility
end

# toggle window border
subscribe modifiers.Alt | modifiers.Shift, key.B do
	windawesome.toggle_show_hide_window_border Windawesome::NativeMethods.get_foreground_window
end

# toggle window menu
subscribe modifiers.Control | modifiers.Alt | modifiers.Shift, key.M do
	windawesome.toggle_show_hide_window_menu get_current_workspace_managed_window
end

# Layout stuff

subscribe modifiers.Alt | modifiers.Shift, key.T do # change layout to Tile
	windawesome.current_workspace.change_layout Windawesome::TileLayout.new
end

subscribe modifiers.Alt | modifiers.Shift, key.M do # change layout to Full Screen
	windawesome.current_workspace.change_layout Windawesome::FullScreenLayout.new
end

subscribe modifiers.Alt | modifiers.Shift, key.F do # change layout to Floating
	windawesome.current_workspace.change_layout Windawesome::FloatingLayout.new
end

# window position stuff

subscribe modifiers.Alt, key.J do
	window = windawesome.current_workspace.get_window get_current_workspace_managed_window
	if window
		next_window = windawesome.current_workspace.get_next_window window
		windawesome.switch_to_application next_window.hWnd if next_window
	elsif Windawesome::NativeMethods.get_foreground_window == Windawesome::NativeMethods::shellWindow and
		windawesome.current_workspace.get_windows.count > 0
		windawesome.switch_to_application windawesome.current_workspace.get_windows.first.value.hWnd
	end
end

subscribe modifiers.Alt, key.K do
	window = windawesome.current_workspace.get_window get_current_workspace_managed_window
	if window
		previous_window = windawesome.current_workspace.get_previous_window window
		windawesome.switch_to_application previous_window.hWnd if previous_window
	elsif Windawesome::NativeMethods.get_foreground_window == Windawesome::NativeMethods::shellWindow and
		windawesome.current_workspace.get_windows.count > 0
		windawesome.switch_to_application windawesome.current_workspace.get_windows.first.value.hWnd
	end
end

subscribe modifiers.Alt | modifiers.Shift, key.J do
	window = windawesome.current_workspace.get_window get_current_workspace_managed_window
	windawesome.current_workspace.shift_window_forward window if window
end

subscribe modifiers.Alt | modifiers.Shift, key.K do
	window = windawesome.current_workspace.get_window get_current_workspace_managed_window
	windawesome.current_workspace.shift_window_backwards window if window
end

subscribe modifiers.Control | modifiers.Alt | modifiers.Shift, key.Return do
	window = windawesome.current_workspace.get_window get_current_workspace_managed_window
	windawesome.current_workspace.shift_window_to_main_position window if window
end

# Tile Layout stuff

subscribe modifiers.Alt | modifiers.Shift, key.L do
	windawesome.current_workspace.layout.toggle_layout_axis if windawesome.current_workspace.layout.layout_name == "Tile"
end

subscribe modifiers.Alt | modifiers.Shift, key.S do
	windawesome.current_workspace.layout.toggle_stack_area_axis if windawesome.current_workspace.layout.layout_name == "Tile"
end

subscribe modifiers.Control | modifiers.Alt | modifiers.Shift, key.S do
	windawesome.current_workspace.layout.toggle_master_area_axis if windawesome.current_workspace.layout.layout_name == "Tile"
end

subscribe modifiers.Alt | modifiers.Shift, key.Left do
	windawesome.current_workspace.layout.add_to_master_area_factor -0.05 if windawesome.current_workspace.layout.layout_name == "Tile"
end

subscribe modifiers.Alt | modifiers.Shift, key.Right do
	windawesome.current_workspace.layout.add_to_master_area_factor if windawesome.current_workspace.layout.layout_name == "Tile"
end

# Workspaces stuff

(1 .. config.workspaces.length).each do |i|
	k = eval("key.D" + i.to_s)

	subscribe modifiers.Alt, k do
		windawesome.switch_to_workspace i
	end

	subscribe modifiers.Alt | modifiers.Shift, k do
		windawesome.change_application_to_workspace get_current_workspace_managed_window, i
	end

	subscribe modifiers.Control | modifiers.Alt | modifiers.Shift, k do
		windawesome.add_application_to_workspace get_current_workspace_managed_window, i
	end
end