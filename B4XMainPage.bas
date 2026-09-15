B4A=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=9.85
@EndOfDesignText@
#Region Shared Files
'#CustomBuildAction: folders ready, %WINDIR%\System32\Robocopy.exe,"..\..\Shared Files" "..\Files"
'Ctrl + click to sync files: ide://run?file=%WINDIR%\System32\Robocopy.exe&args=..\..\Shared+Files&args=..\Files&FilesSync=True
#End Region

#Macro: Title, Export B4XPages, ide://run?File=%B4X%\Zipper.jar&Args=%PROJECT_NAME%.zip

' ==========================================================
' Full working example for a GNOME-style Quick Settings Dropdown
' Target: B4J Desktop Application (B4XPages Template)
' Dependencies: XUI, jCustomListView, JavaObject, StringUtils
' =============================================================

Sub Class_Globals
	Private Root As B4XView 'Assuming B4XPages template
	Private xui As XUI
	
	' Core Container Layouts
	Private pnlMain As B4XView          ' Main dashboard background
	Private pnlTopBar As B4XView        ' The static top system bar
	Private pnlQuickSettings As B4XView ' The floating GNOME card panel
	
	' Top Bar Buttons
	Private btnSettingsTrigger As B4XView
	Private lblTriggerNotifIcon As B4XView
	Private lblTriggerBatteryIcon As B4XView
	Private lblTriggerBatteryBolt As B4XView
	Private lblTriggerBatteryPct As B4XView
	
	' Inside Quick Settings Layout Views
	Private clvNotifications As CustomListView ' <-- Linked from your MainPage designer layout
	Private lblVolumePct As B4XView
	Private btnClearAll As B4XView
	Private lblEmptyNotifications As B4XView
	Private lblWifiIcon As B4XView
	Private lblBTIcon As B4XView
	Private volSeek As B4XSeekBar
	Private volBase As B4XView
	
	' State Tracking
	Private isDrawerOpen As Boolean = False
	Private panelWidth As Int = 340dip
	Private panelHeight As Int = 430dip
	Private topOffset As Int = 50dip ' Height of the top bar
	
	' CLV slot inside the drawer card (single source of truth -- see PinCLVToDrawer).
	' The CLV is a reparented designer view (MainPage.bjl slot is 15,160,310x240),
	' so it must always be positioned with literal coordinates, never read-backs.
	Private clvTop As Int = 160dip
	Private clvH As Int = 240dip
End Sub

Public Sub Initialize
End Sub

Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	
	' 1. BUILD THE UI LAYOUTS AND NEST DESIGNER ELEMENTS
	BuildProgrammaticUI
	
	' 2. INITIAL COMPONENT STATES
	lblVolumePct.Text = "75%"
	
	' Populating dummy system notifications mimicking Linux Desktop
	clvNotifications.Add(CreateNotificationItem("System Update", "Security patch ready to install.", "10m ago"), "")
	clvNotifications.Add(CreateNotificationItem("Network Manager", "Connected to Wi-Fi: Secure_Office_5G", "45m ago"), "")
	'clvNotifications.Add(CreateNotificationItem("Backup System", "Daily snapshot completed successfully.", "2h ago"), "")
	'clvNotifications.Add(CreateNotificationItem("System Update", "Security patch ready to install.", "10m ago"), "")
	'clvNotifications.Add(CreateNotificationItem("Network Manager", "Connected to Wi-Fi: Secure_Office_5G", "45m ago"), "")
	'clvNotifications.Add(CreateNotificationItem("Backup System", "Daily snapshot completed successfully.", "2h ago"), "")
	
	' 3. RE-CALCULATE DRAWER HEIGHT DYNAMICALLY WITHOUT BREAKING RENDERS
	ResizeDrawerToContent
End Sub

' Mathematically handles window resizing dynamically
Private Sub B4XPage_Resize (Width As Int, Height As Int)
	pnlTopBar.SetLayoutAnimated(0, 0, 0, Width, topOffset)
	pnlMain.SetLayoutAnimated(0, 0, topOffset, Width, Height - topOffset)
	
	' Anchor the trigger to the upper far-right tray boundary
	btnSettingsTrigger.SetLayoutAnimated(0, Width - btnSettingsTrigger.Width - 15dip, btnSettingsTrigger.Top, btnSettingsTrigger.Width, btnSettingsTrigger.Height)
	
	' Maintain float alignment layout positioning rules for the card drop calculations
	Dim targetLeft As Int = Width - panelWidth - 15dip
	Dim targetTop As Int = IIf(isDrawerOpen, topOffset + 5dip, -panelHeight - 200dip)
	
	pnlQuickSettings.SetLayoutAnimated(0, targetLeft, targetTop, panelWidth, panelHeight)
	
	' Window resizes can stretch the reparented designer CLV beyond the card --
	' force it back into its slot (cheap and idempotent).
	PinCLVToDrawer
End Sub

' --- INTERACTION LAYER ---

Private Sub btnSettingsTrigger_Click
	Dim targetLeft As Int = Root.Width - panelWidth - 15dip
	
	If isDrawerOpen Then
		pnlQuickSettings.SetLayoutAnimated(220, targetLeft, -panelHeight - 200dip, panelWidth, panelHeight)
		isDrawerOpen = False
		btnSettingsTrigger.Color = 0x00FFFFFF
		Sleep(230)
		' Only hide if it is still closed (prevents flicker when user re-opens quickly
		' and guarantees no sliver/shadow peeks when the drawer is short, e.g. <= 2 items).
		If isDrawerOpen = False Then pnlQuickSettings.Visible = False
	Else
		pnlQuickSettings.Visible = True
		pnlQuickSettings.BringToFront
		pnlQuickSettings.SetLayoutAnimated(250, targetLeft, topOffset + 5dip, panelWidth, panelHeight)
		isDrawerOpen = True
		btnSettingsTrigger.Color = 0x22FFFFFF
		Sleep(260)
		' Re-pin after the drop animation in case layout passes stretched the CLV mid-flight.
		If isDrawerOpen Then PinCLVToDrawer
	End If
End Sub

' Pane capsule was changed from Button (Click) to Pane - Pane routes via Touch,
' not Click, so this wires the capsule. Child icons are mouseTransparent so the
' Pane receives the hit.
Private Sub btnSettingsTrigger_Touch (Action As Int, X As Float, Y As Float)
	If Action = 0 Then btnSettingsTrigger_Click
End Sub

Private Sub pnlMain_Touch (Action As Int, X As Float, Y As Float)
	If isDrawerOpen And Action = 0 Then
		btnSettingsTrigger_Click 
	End If
End Sub

Private Sub pnlQuickSettings_Touch (Action As Int, X As Float, Y As Float)
	' Intentionally left blank to capture clicks and prevent dissipation
End Sub

' --- UI INTERACTION STUBS (Quick Settings Controls) ---

Private Sub btnWifi_Click
	Dim btn As B4XView = Sender
	If btn.Color = 0xFF3584E4 Then 
		btn.Color = 0xFF363636
		btn.Text = "    Wi-Fi: Off"
		xui.MsgboxAsync("Wi-Fi Interface Disabled", "System Settings")
	Else
		btn.Color = 0xFF3584E4
		btn.Text = "    Wi-Fi: On"
	End If
End Sub

Private Sub btnBluetooth_Click
	Dim btn As B4XView = Sender
	If btn.Color = 0xFF3584E4 Then
		btn.Color = 0xFF363636
	Else
		btn.Color = 0xFF3584E4
	End If
End Sub

Private Sub btnSliderVolUp_Click
	volSeek.Value = Min(100, volSeek.Value + 5)
	lblVolumePct.Text = volSeek.Value & "%"
End Sub

Private Sub btnSliderVolDown_Click
	volSeek.Value = Max(0, volSeek.Value - 5)
	lblVolumePct.Text = volSeek.Value & "%"
End Sub

Private Sub volSeek_ValueChanged (Value As Int)
	lblVolumePct.Text = Value & "%"
End Sub

' Clears the notification feed and shrinks the drawer to its empty state
Private Sub btnClearAll_Click
	If clvNotifications.Size = 0 Then Return
	clvNotifications.Clear
	ResizeDrawerToContent
End Sub

' Helper script generating beautiful nested notification blocks programmatically
Private Sub CreateNotificationItem(Title As String, Body As String, TimeStr As String) As B4XView
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, panelWidth - 30dip, 65dip)
	p.Color = 0xFF2D2D2D
	
	Private lblTitle As Label
	lblTitle.Initialize("")
	Dim bxlTitle As B4XView = lblTitle
	bxlTitle.Text = Title
	bxlTitle.TextColor = 0xFFFFFFFF
	bxlTitle.Font = xui.CreateDefaultBoldFont(13)
	p.AddView(bxlTitle, 10dip, 8dip, 180dip, 20dip)
	
	Private lblTime As Label
	lblTime.Initialize("")
	Dim bxlTime As B4XView = lblTime
	bxlTime.Text = TimeStr
	bxlTime.TextColor = 0x88FFFFFF
	bxlTime.Font = xui.CreateDefaultFont(11)
	p.AddView(bxlTime, p.Width - 80dip, 8dip, 70dip, 20dip)
	
	Private lblBody As Label
	lblBody.Initialize("")
	Dim bxlBody As B4XView = lblBody
	bxlBody.Text = Body
	bxlBody.TextColor = 0xDDFFFFFF
	bxlBody.Font = xui.CreateDefaultFont(12)
	p.AddView(bxlBody, 10dip, 28dip, p.Width - 20dip, 30dip)
	
	Return p
End Sub

Private Sub BuildProgrammaticUI
	Root.Color = 0xFF1E1E1E
	
	' 1. Load the designer layout file first so custom views are fully instantiated
	Root.LoadLayout("MainPage")
	
	' Top Bar Panel
	Dim p1 As Pane
	p1.Initialize("")
	pnlTopBar = p1
	pnlTopBar.Color = 0xFF101010
	Root.AddView(pnlTopBar, 0, 0, Root.Width, topOffset)
	
	' System Tray Time Label
	Dim lblClock As Label
	lblClock.Initialize("")
	Dim bxlClock As B4XView = lblClock
	bxlClock.Text = CurrentTime
	bxlClock.TextColor = 0xFFFFFFFF
	bxlClock.Font = xui.CreateDefaultBoldFont(13)
	pnlTopBar.AddView(bxlClock, 20dip, 15dip, 200dip, 20dip)
	
	' GNOME Capsule Style Trigger Button - notification + battery charging icons (FontAwesome)
	' Composite Pane so icon glyphs can use FA font while the percentage uses the default font
	Dim pTrig As Pane
	pTrig.Initialize("btnSettingsTrigger")
	btnSettingsTrigger = pTrig
	pnlTopBar.AddView(btnSettingsTrigger, Root.Width - 120dip, 10dip, 105dip, 30dip)
	Dim joBtn As JavaObject = btnSettingsTrigger
	joBtn.RunMethod("setStyle", Array("-fx-background-radius: 15px; -fx-border-radius: 15px; -fx-border-color: #444444; -fx-cursor: hand; -fx-background-color: transparent;"))
	joBtn.RunMethod("setPickOnBounds", Array(True))
	
	Dim lblTN As Label
	lblTN.Initialize("")
	lblTriggerNotifIcon = lblTN
	lblTriggerNotifIcon.Text = Chr(0xF0F3) ' FA bell = notifications
	lblTriggerNotifIcon.TextColor = 0xFFFFFFFF
	lblTriggerNotifIcon.Font = xui.CreateFontAwesome(13)
	btnSettingsTrigger.AddView(lblTriggerNotifIcon, 14dip, 7dip, 16dip, 16dip)
	Dim joTN As JavaObject = lblTriggerNotifIcon
	joTN.RunMethod("setMouseTransparent", Array(True))
	
	Dim lblTB As Label
	lblTB.Initialize("")
	lblTriggerBatteryIcon = lblTB
	lblTriggerBatteryIcon.Text = Chr(0xF240) ' FA battery full
	lblTriggerBatteryIcon.TextColor = 0xFFFFFFFF
	lblTriggerBatteryIcon.Font = xui.CreateFontAwesome(14)
	btnSettingsTrigger.AddView(lblTriggerBatteryIcon, 34dip, 7dip, 18dip, 16dip)
	Dim joTB As JavaObject = lblTriggerBatteryIcon
	joTB.RunMethod("setMouseTransparent", Array(True))
	
	' Small bolt overlay inside the battery to convey "charging"
	Dim lblTBBolt As Label
	lblTBBolt.Initialize("")
	lblTriggerBatteryBolt = lblTBBolt
	lblTriggerBatteryBolt.Text = Chr(0xF0E7) ' FA bolt
	lblTriggerBatteryBolt.TextColor = 0xFF1A1A1A ' dark bolt so it reads inside the white battery; change to white if you prefer outline style
	lblTriggerBatteryBolt.Font = xui.CreateFontAwesome(7)
	btnSettingsTrigger.AddView(lblTriggerBatteryBolt, 40dip, 10dip, 8dip, 10dip)
	Dim joTBBolt As JavaObject = lblTriggerBatteryBolt
	joTBBolt.RunMethod("setMouseTransparent", Array(True))
	
	Dim lblTPct As Label
	lblTPct.Initialize("")
	lblTriggerBatteryPct = lblTPct
	lblTriggerBatteryPct.Text = "98%"
	lblTriggerBatteryPct.TextColor = 0xFFFFFFFF
	lblTriggerBatteryPct.Font = xui.CreateDefaultFont(12)
	btnSettingsTrigger.AddView(lblTriggerBatteryPct, 56dip, 7dip, 38dip, 16dip)
	Dim joTPct As JavaObject = lblTriggerBatteryPct
	joTPct.RunMethod("setMouseTransparent", Array(True))
	
	' Main Content Panel Workspace Canvas
	Dim p2 As Pane
	p2.Initialize("pnlMain")
	pnlMain = p2
	pnlMain.Color = 0xFF1A1A1A
	Root.AddView(pnlMain, 0, topOffset, Root.Width, Root.Height - topOffset)
	
	Dim lblCenter As Label
	lblCenter.Initialize("")
	Dim bxlCenter As B4XView = lblCenter
	bxlCenter.Text = "Click the top-right tray capsule to test the dropdown drawer."
	bxlCenter.TextColor = 0x44FFFFFF
	pnlMain.AddView(bxlCenter, 40dip, 100dip, 500dip, 40dip)
	
	' Quick Settings Container Overlay Card (semi-transparent frosted card + blurred drop shadow)
	' NOTE: background color lives inside the CSS string. Do NOT use pnlQuickSettings.Color here,
	' because B4J setStyle would wipe it (and vice versa). JavaFX has no backdrop-filter, so the
	' "blur" is a soft gaussian drop shadow plus translucency, i.e. a frosted-glass profile.
	Dim p3 As Pane
	p3.Initialize("pnlQuickSettings")
	pnlQuickSettings = p3
	Root.AddView(pnlQuickSettings, Root.Width - panelWidth - 15dip, -panelHeight - 200dip, panelWidth, panelHeight)
	pnlQuickSettings.Visible = False ' Start fully hidden so no sliver shows before first open
	
	Dim joPanel As JavaObject = pnlQuickSettings
	joPanel.RunMethod("setStyle", Array("-fx-background-color: rgba(36,36,36,0.78); -fx-background-radius: 18px; -fx-border-radius: 18px; -fx-border-color: rgba(255,255,255,0.12); -fx-border-width: 1px; -fx-effect: dropshadow(gaussian, rgba(0,0,0,0.55), 28, 0.15, 0, 10);"))
	
	' Pill Toggles (Row 1) - GNOME-style pill buttons with FontAwesome icon glyphs
	Dim btnWifi As Button
	btnWifi.Initialize("btnWifi")
	Dim bxlWifi As B4XView = btnWifi
	bxlWifi.Text = "    Wi-Fi: On"
	pnlQuickSettings.AddView(bxlWifi, 20dip, 20dip, 140dip, 45dip)
	Dim joW As JavaObject = bxlWifi
	joW.RunMethod("setStyle", Array("-fx-background-radius: 20px; -fx-cursor: hand; -fx-alignment: center;"))
	bxlWifi.Color = 0xFF3584E4
	bxlWifi.TextColor = 0xFFFFFFFF
		
	Dim btnBT As Button
	btnBT.Initialize("btnBluetooth")
	Dim bxlBT As B4XView = btnBT
	bxlBT.Text = "    Bluetooth"
	pnlQuickSettings.AddView(bxlBT, 180dip, 20dip, 140dip, 45dip)
	Dim joB As JavaObject = bxlBT
	joB.RunMethod("setStyle", Array("-fx-background-radius: 20px; -fx-cursor: hand; -fx-alignment: center;"))
	bxlBT.Color = 0xFF363636
	bxlBT.TextColor = 0xFFFFFFFF
	
	' FontAwesome icon overlays (separate labels so the text font stays default
	' while icons render with the FA font - mixing fonts in one Button isn't supported).
	Dim lblW As Label
	lblW.Initialize("")
	lblWifiIcon = lblW
	lblWifiIcon.Text = Chr(0xF1EB) ' FA wifi
	lblWifiIcon.TextColor = 0xFFFFFFFF
	lblWifiIcon.Font = xui.CreateFontAwesome(15)
	' Center the glyph inside the left side of the Wi-Fi pill
	pnlQuickSettings.AddView(lblWifiIcon, 34dip, 32dip, 20dip, 20dip)
	Dim joWifiIcon As JavaObject = lblWifiIcon
	joWifiIcon.RunMethod("setMouseTransparent", Array(True))
	
	Dim lblB As Label
	lblB.Initialize("")
	lblBTIcon = lblB
	lblBTIcon.Text = Chr(0xF293) ' FA bluetooth
	lblBTIcon.TextColor = 0xFFFFFFFF
	lblBTIcon.Font = xui.CreateFontAwesome(15)
	pnlQuickSettings.AddView(lblBTIcon, 194dip, 32dip, 20dip, 20dip)
	Dim joBTIcon As JavaObject = lblBTIcon
	joBTIcon.RunMethod("setMouseTransparent", Array(True))
		
	' Volume Adjustments (Row 2) - GNOME style slider themed to frosted card
	Dim lblVol As Label
	lblVol.Initialize("")
	Dim bxlVol As B4XView = lblVol
	bxlVol.Text = Chr(0xF028) ' FA volume-up icon
	bxlVol.TextColor = 0xFFFFFFFF
	bxlVol.Font = xui.CreateFontAwesome(14)
	pnlQuickSettings.AddView(bxlVol, 20dip, 86dip, 22dip, 24dip)
	Dim joVolIcon As JavaObject = bxlVol
	joVolIcon.RunMethod("setMouseTransparent", Array(True))
	
	Dim lblVolTxt As Label
	lblVolTxt.Initialize("")
	Dim bxlVolTxt As B4XView = lblVolTxt
	bxlVolTxt.Text = "Volume"
	bxlVolTxt.TextColor = 0xDDFFFFFF
	bxlVolTxt.Font = xui.CreateDefaultFont(12)
	pnlQuickSettings.AddView(bxlVolTxt, 44dip, 87dip, 46dip, 22dip)
	
	' Minus stepper (themed circular)
	Dim btnVDown As Button
	btnVDown.Initialize("btnSliderVolDown")
	Dim bxlVD As B4XView = btnVDown
	bxlVD.Text = Chr(0xF068) ' FA minus
	bxlVD.TextColor = 0xFFFFFFFF
	bxlVD.Font = xui.CreateFontAwesome(10)
	pnlQuickSettings.AddView(bxlVD, 92dip, 86dip, 26dip, 26dip)
	Dim joVD As JavaObject = bxlVD
	joVD.RunMethod("setStyle", Array("-fx-background-color: rgba(255,255,255,0.10); -fx-background-radius: 13px; -fx-border-radius: 13px; -fx-border-color: rgba(255,255,255,0.14); -fx-border-width: 1px; -fx-cursor: hand;"))
	
	' Slider track (B4XSeekBar - themed to GNOME accent)
	Dim basePanel As B4XView = xui.CreatePanel("")
	volBase = basePanel
	volBase.SetLayoutAnimated(0, 0, 0, 120dip, 22dip)
	pnlQuickSettings.AddView(volBase, 124dip, 88dip, 120dip, 22dip)
	Dim tmpLbl As Label
	tmpLbl.Initialize("")
	Dim props As Map
	props.Initialize
	props.Put("Min", 0)
	props.Put("Max", 100)
	props.Put("Value", 75)
	props.Put("Interval", 1)
	props.Put("Color1", 0xFF3584E4)       ' filled + thumb (GNOME blue)
	props.Put("Color2", 0x33FFFFFF)       ' empty track (translucent white on frosted)
	props.Put("ThumbColor", 0x403584E4)   ' pressed halo
	volSeek.Initialize(Me, "volSeek")
	volSeek.DesignerCreateView(volBase, tmpLbl, props)
	volSeek.Base_Resize(120dip, 22dip)
	
	' Plus stepper (themed circular)
	Dim btnVUp As Button
	btnVUp.Initialize("btnSliderVolUp")
	Dim bxlVU As B4XView = btnVUp
	bxlVU.Text = Chr(0xF067) ' FA plus
	bxlVU.TextColor = 0xFFFFFFFF
	bxlVU.Font = xui.CreateFontAwesome(10)
	pnlQuickSettings.AddView(bxlVU, 250dip, 86dip, 26dip, 26dip)
	Dim joVU As JavaObject = bxlVU
	joVU.RunMethod("setStyle", Array("-fx-background-color: rgba(255,255,255,0.10); -fx-background-radius: 13px; -fx-border-radius: 13px; -fx-border-color: rgba(255,255,255,0.14); -fx-border-width: 1px; -fx-cursor: hand;"))
	
	Dim lblVVal As Label
	lblVVal.Initialize("")
	lblVolumePct = lblVVal
	lblVolumePct.Text = "75%"
	lblVolumePct.TextColor = 0xFFFFFFFF
	lblVolumePct.Font = xui.CreateDefaultFont(12)
	pnlQuickSettings.AddView(lblVolumePct, 282dip, 86dip, 38dip, 24dip)
	
	' Notification Feed Setup (Row 3)
	Dim lblNotifHeader As Label
	lblNotifHeader.Initialize("")
	Dim bxlNH As B4XView = lblNotifHeader
	bxlNH.Text = "Notifications"
	bxlNH.TextColor = 0xAAFFFFFF
	bxlNH.Font = xui.CreateDefaultBoldFont(12)
	pnlQuickSettings.AddView(bxlNH, 20dip, 135dip, 150dip, 20dip)
	
	' "Clear All" pill button, right-aligned on the same header row
	Dim btnC As Button
	btnC.Initialize("btnClearAll")
	btnClearAll = btnC
	btnClearAll.Text = "Clear All"
	btnClearAll.TextColor = 0xFFFFFFFF
	btnClearAll.Font = xui.CreateDefaultFont(11)
	pnlQuickSettings.AddView(btnClearAll, panelWidth - 110dip, 132dip, 90dip, 24dip)
	Dim joClear As JavaObject = btnClearAll
	joClear.RunMethod("setStyle", Array("-fx-background-color: rgba(255,255,255,0.08); -fx-background-radius: 12px; -fx-border-radius: 12px; -fx-border-color: rgba(255,255,255,0.18); -fx-border-width: 1px; -fx-cursor: hand;"))
	
	' FIXED: Do NOT initialize clvNotifications. It's already built by Root.LoadLayout!
	' Instead, we fetch its Base View panel and target its position inside the card wrapper.
	Dim clvBasePanel As B4XView = clvNotifications.GetBase
	
	' Remove it from the root layout layer and nest it safely inside our floating drawer card instead
	clvBasePanel.RemoveViewFromParent
	pnlQuickSettings.AddView(clvBasePanel, 15dip, clvTop, panelWidth - 30dip, clvH)
	
	' Transparent list so the frosted card shows through (opaque gray here would paint a solid
	' rectangle inside the semi-transparent drawer).
	clvNotifications.sv.Color = xui.Color_Transparent
	CallSubDelayed3(Me, "SetScrollPaneBackgroundColor", clvNotifications, xui.Color_Transparent)
	
	' Empty-state placeholder, overlaid on the CLV area and toggled in ResizeDrawerToContent
	Dim lblEmpty As Label
	lblEmpty.Initialize("")
	lblEmptyNotifications = lblEmpty
	lblEmptyNotifications.Text = "No new notifications"
	lblEmptyNotifications.TextColor = 0x88FFFFFF
	lblEmptyNotifications.Font = xui.CreateDefaultFont(12)
	pnlQuickSettings.AddView(lblEmptyNotifications, 20dip, clvTop, panelWidth - 40dip, 40dip)
	lblEmptyNotifications.Visible = False
	
	StyleCustomScrollbar(clvNotifications)
	
	' Kill the default designer/scrollpane outline so no bordered box can paint outside the card.
	' Applied AFTER StyleCustomScrollbar so it wins over the fallback inline style there.
	Dim joSV As JavaObject = clvNotifications.sv
	joSV.RunMethod("setStyle", Array("-fx-background-color: transparent; -fx-border-color: transparent; -fx-border-width: 0;"))
	Dim joBase As JavaObject = clvNotifications.GetBase
	joBase.RunMethod("setStyle", Array("-fx-background-color: transparent; -fx-border-color: transparent; -fx-border-width: 0;"))
	
	PinCLVToDrawer
	pnlQuickSettings.BringToFront
End Sub

Sub CurrentTime As String
	Dim DF As String = DateTime.DateFormat
	DateTime.DateFormat = "MMM dd, h:mm a"
	Dim CT As String = DateTime.Date(DateTime.Now)
	DateTime.DateFormat = DF
	Return CT
End Sub

Sub SetScrollPaneBackgroundColor (View As CustomListView, Color As Int)
	Dim SP As JavaObject = View.GetBase.GetView(0)
	Dim V As B4XView = SP
	V.Color = Color
	Dim V As B4XView = SP.RunMethod("lookup", Array(".viewport"))
	V.Color = Color
End Sub

' Styles the CustomListView scrollbar to match the dark GNOME theme
Private Sub StyleCustomScrollbar (clvItem As CustomListView)
	' Get the native JavaFX ScrollPane from the CLV ScrollView
	Dim joSP As JavaObject = clvItem.sv
	
	' Custom CSS string targeting JavaFX scrollbar components
	Dim sbStyle As String = _
		".scroll-bar:vertical {" & _
		"    -fx-background-color: transparent;" & _
		"    -fx-width: 8px;" & _
		"}" & _
		".scroll-bar:vertical .track {" & _
		"    -fx-background-color: transparent;" & _
		"}" & _
		".scroll-bar:vertical .thumb {" & _
		"    -fx-background-color: #4A4A4A;" & _
		"    -fx-background-radius: 4px;" & _
		"}" & _
		".scroll-bar:vertical .thumb:hover {" & _
		"    -fx-background-color: #5C5C5C;" & _
		"}" & _
		".scroll-bar .increment-button, .scroll-bar .decrement-button {" & _
		"    -fx-background-color: transparent;" & _
		"    -fx-padding: 0 0 0 0;" & _
		"}" & _
		".scroll-bar .increment-arrow, .scroll-bar .decrement-arrow {" & _
		"    -fx-shape: ' ';" & _
		"    -fx-padding: 0 0 0 0;" & _
		"}"
	
	' Apply inline stylesheet via JavaFX code implementation
	Dim scene As JavaObject = joSP.RunMethod("getScene", Null)
	If scene.IsInitialized Then
		' If the scene is already active, inject via data URL style sheet string
		Dim base64 As String = StringToBase64(sbStyle)
		Dim url As String = "data:text/css;base64," & base64
		Dim stylesheets As JavaObject = scene.RunMethod("getStylesheets", Null)
		stylesheets.RunMethod("add", Array(url))
	Else
		' Safe fallback direct styling approach on the component itself if called early
		joSP.RunMethod("setStyle", Array("-fx-scrollbar-color: #4A4A4A transparent;"))
	End If
End Sub

' Helper utility to parse the string safely for JavaFX stylesheet injection
Private Sub StringToBase64 (Text As String) As String
	Dim su As StringUtils
	Dim bytes() As Byte = Text.GetBytes("UTF8")
	Return su.EncodeBase64(bytes)
End Sub

' Dynamically sizes the CLV and the GNOME settings panel based on item count
Private Sub ResizeDrawerToContent
	' 1. Calculate the combined height of all items safely
	Dim totalItemsHeight As Int = 0
	If clvNotifications.Size > 0 Then
		For i = 0 To clvNotifications.Size - 1
			Dim p As B4XView = clvNotifications.GetPanel(i)
			If p.IsInitialized Then
				totalItemsHeight = totalItemsHeight + p.Height
			Else
				totalItemsHeight = totalItemsHeight + 65dip ' Default placeholder fallback row height
			End If
		Next
	End If
	
	' Set layout bounds constraints
	Dim minClvHeight As Int = 40dip
	Dim maxClvHeight As Int = 240dip
	Dim targetClvHeight As Int = Max(minClvHeight, Min(totalItemsHeight, maxClvHeight))
	
	' 2. Pin the reparented designer CLV to its exact slot inside the drawer card.
	' Always use literal coordinates here -- reading back Left/Top/Width can return
	' stale (e.g. designer-size) values and leave the list taller than the card.
	clvH = targetClvHeight
	PinCLVToDrawer
	
	' 3. Calculate new total height for the outer GNOME drawer panel container.
	' By construction the list bottom (clvTop + clvH) always sits 20dip above the card bottom,
	' so the CLV can never overflow the panel.
	panelHeight = clvTop + targetClvHeight + 20dip
	
	' 3b. Empty state: show placeholder and disable Clear All when there is nothing to clear
	If btnClearAll.IsInitialized Then btnClearAll.Enabled = (clvNotifications.Size > 0)
	If lblEmptyNotifications.IsInitialized Then lblEmptyNotifications.Visible = (clvNotifications.Size = 0)
	
	' 4. Instantly shift or anchor the panel location based on state
	Dim targetLeft As Int = Root.Width - panelWidth - 15dip
	If isDrawerOpen Then
		pnlQuickSettings.SetLayoutAnimated(0, targetLeft, topOffset + 5dip, panelWidth, panelHeight)
		pnlQuickSettings.Visible = True
	Else
		pnlQuickSettings.SetLayoutAnimated(0, targetLeft, -panelHeight - 200dip, panelWidth, panelHeight)
		pnlQuickSettings.Visible = False
	End If
	
	pnlQuickSettings.BringToFront
End Sub

' Forces the reparented designer CLV back into its exact slot inside the drawer card.
' The CLV is created by MainPage.bjl and moved into pnlQuickSettings at runtime, so window
' resizes or open/close animations can leave it stretched beyond the card (a plain Pane does
' not clip children, so the overflow paints outside the card as in the bug screenshot).
' Kept as one helper so every card move (resize, toggle, content change) re-pins it.
Private Sub PinCLVToDrawer
	Dim clvBase As B4XView = clvNotifications.GetBase
	clvBase.SetLayoutAnimated(0, 15dip, clvTop, panelWidth - 30dip, clvH)
	clvNotifications.Base_Resize(panelWidth - 30dip, clvH) ' Forces internal Scrollview content rebuild
End Sub
