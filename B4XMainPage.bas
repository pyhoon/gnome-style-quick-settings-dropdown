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

' B4J ==========================================
' Full working example for a GNOME-style Quick Settings Dropdown
' Target: B4J Desktop Application (B4XPages Template Preferred)
' Dependecies: XUI, jCustomListView
' =============================================

Sub Class_Globals
	Private Root As B4XView 'Assuming B4XPages template
	Private xui As XUI
	
	' Core Container Layouts
	Private pnlMain As B4XView          ' Main dashboard background
	Private pnlTopBar As B4XView        ' The static top system bar
	Private pnlQuickSettings As B4XView ' The floating GNOME card panel
	
	' Top Bar Buttons
	Private btnSettingsTrigger As B4XView
	
	' Inside Quick Settings Layout Views
	Private clvNotifications As CustomListView
	Private lblVolumePct As B4XView
	'Private lblBrightnessPct As B4XView
	
	' State Tracking
	Private isDrawerOpen As Boolean = False
	Private panelWidth As Int = 340dip
	Private panelHeight As Int = 450dip
	Private topOffset As Int = 50dip ' Height of the top bar
End Sub

Public Sub Initialize
End Sub

' This event will handle programmatic layout creation if you prefer bypassing the visual designer
Private Sub B4XPage_Created (Root1 As B4XView)
	Root = Root1
	Root.LoadLayout("MainPage")
	
	' 1. BUILD THE UI LAYOUTS PROGRAMMATICALLY FOR PLUG-AND-PLAY UTILITY
	BuildProgrammaticUI
	
	' 2. INITIAL COMPONENT STATES
	lblVolumePct.Text = "75%"
	'lblBrightnessPct.Text = "80%"
	
	' Populating dummy system notifications mimicking Linux Desktop
	clvNotifications.Add(CreateNotificationItem("System Update", "Security patch ready to install.", "10m ago"), "")
	clvNotifications.Add(CreateNotificationItem("Network Manager", "Connected to Wi-Fi: Secure_Office_5G", "45m ago"), "")
	clvNotifications.Add(CreateNotificationItem("Backup System", "Daily snapshot completed successfully.", "2h ago"), "")
	
	' Position the GNOME panel cleanly out of view initially
	HidePanelImmediately
End Sub

' Mathematically handles window resizing dynamically
Private Sub B4XPage_Resize (Width As Int, Height As Int)
	pnlTopBar.SetLayoutAnimated(0, 0, 0, Width, topOffset)
	pnlMain.SetLayoutAnimated(0, 0, topOffset, Width, Height - topOffset)
	
	' Anchor the trigger to the upper far-right tray boundary
	btnSettingsTrigger.SetLayoutAnimated(0, Width - btnSettingsTrigger.Width - 15dip, btnSettingsTrigger.Top, btnSettingsTrigger.Width, btnSettingsTrigger.Height)
	
	' Maintain float alignment layout positioning rules for the card drop calculations
	Dim targetLeft As Int = Width - panelWidth - 15dip
	Dim targetTop As Int = IIf(isDrawerOpen, topOffset + 5dip, -panelHeight)
	
	' FIXED: Changed from .SetLayout to .SetLayoutAnimated with 0 duration
	pnlQuickSettings.SetLayoutAnimated(0, targetLeft, targetTop, panelWidth, panelHeight)
End Sub

' --- INTERACTION LAYER ---

' Triggered by clicking the custom multi-segment status button inside your upper menu bar
Private Sub btnSettingsTrigger_Click
	Dim targetLeft As Int = Root.Width - panelWidth - 15dip
	
	If isDrawerOpen Then
		' Retract up seamlessly out of site
		pnlQuickSettings.SetLayoutAnimated(220, targetLeft, -panelHeight, panelWidth, panelHeight)
		isDrawerOpen = False
		' Change panel indicator color back to baseline
		btnSettingsTrigger.Color = 0x00FFFFFF ' Transparent standard
	Else
		' Snap out and descend gracefully right beneath your tray icon
		pnlQuickSettings.SetLayoutAnimated(250, targetLeft, topOffset + 5dip, panelWidth, panelHeight)
		isDrawerOpen = True
		' Give active status visual context highlight
		btnSettingsTrigger.Color = 0x22FFFFFF ' Subtle selection highlight
	End If
End Sub

' UX Feature: Clicking outside onto your main UI components instantly closes the tray window
Private Sub pnlMain_Touch (Action As Int, X As Float, Y As Float)
	' 0 evaluates directly to the standard screen ACTION_DOWN action
	If isDrawerOpen And Action = 0 Then
		btnSettingsTrigger_Click ' Toggles active states cleanly back to false
	End If
End Sub

' Explicitly consume panel clicks to stop event propagation leaking into background views
Private Sub pnlQuickSettings_Touch (Action As Int, X As Float, Y As Float)
	' Keeping this empty blocks child bubbles from trickling downwards
End Sub

' --- UI INTERACTION STUBS (Quick Settings Controls) ---

Private Sub btnWifi_Click
	Dim btn As B4XView = Sender
	' Toggle pill color background state mockups
	If btn.Color = 0xFF3584E4 Then ' GNOME Blue accent
		btn.Color = 0xFF363636     ' Standard Dark grey button background
		xui.MsgboxAsync("Wi-Fi Interface Disabled", "System Settings")
	Else
		btn.Color = 0xFF3584E4
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
	lblVolumePct.Text = "85%"
End Sub

Private Sub btnSliderVolDown_Click
	lblVolumePct.Text = "65%"
End Sub

' --- DRAWING ARCHITECTURE UTILITIES ---

' FIXED: Changed from Instant .SetLayout to .SetLayoutAnimated with 0 duration
Private Sub HidePanelImmediately
	pnlQuickSettings.SetLayoutAnimated(0, Root.Width - panelWidth - 15dip, -panelHeight, panelWidth, panelHeight)
	isDrawerOpen = False
End Sub

' Helper script generating beautiful nested notification blocks programmatically
Private Sub CreateNotificationItem(Title As String, Body As String, TimeStr As String) As B4XView
	Dim p As B4XView = xui.CreatePanel("")
	p.SetLayoutAnimated(0, 0, 0, panelWidth - 30dip, 65dip)
	p.Color = 0xFF2D2D2D
	
	' Title String styling
	Private lblTitle As Label
	lblTitle.Initialize("")
	Dim bxlTitle As B4XView = lblTitle
	bxlTitle.Text = Title
	bxlTitle.TextColor = 0xFFFFFFFF
	bxlTitle.Font = xui.CreateDefaultBoldFont(13)
	p.AddView(bxlTitle, 10dip, 8dip, 180dip, 20dip)
	
	' Timing string alignment
	Private lblTime As Label
	lblTime.Initialize("")
	Dim bxlTime As B4XView = lblTime
	bxlTime.Text = TimeStr
	bxlTime.TextColor = 0x88FFFFFF
	bxlTime.Font = xui.CreateDefaultFont(11)
	p.AddView(bxlTime, p.Width - 80dip, 8dip, 70dip, 20dip)
	
	' Body Content layout block
	Private lblBody As Label
	lblBody.Initialize("")
	Dim bxlBody As B4XView = lblBody
	bxlBody.Text = Body
	bxlBody.TextColor = 0xDDFFFFFF
	bxlBody.Font = xui.CreateDefaultFont(12)
	p.AddView(bxlBody, 10dip, 28dip, p.Width - 20dip, 30dip)
	
	Return p
End Sub

' Programmatic UI Generator for seamless project portability
Private Sub BuildProgrammaticUI
	Root.Color = 0xFF1E1E1E
	
	' FIXED: Changed 'Panel' declarations to 'Pane' for B4J
	' Top Bar Panel
	Dim p1 As Pane : p1.Initialize("") : pnlTopBar = p1
	pnlTopBar.Color = 0xFF101010
	Root.AddView(pnlTopBar, 0, 0, Root.Width, topOffset)
	
	' System Tray Time Label
	Dim lblClock As Label : lblClock.Initialize("") : Dim bxlClock As B4XView = lblClock
	bxlClock.Text = "Sep 15, 1:57 PM"
	bxlClock.TextColor = 0xFFFFFFFF
	bxlClock.Font = xui.CreateDefaultBoldFont(13)
	pnlTopBar.AddView(bxlClock, 20dip, 15dip, 150dip, 20dip)
	
	' GNOME Capsule Style Trigger Button
	Dim b1 As Button : b1.Initialize("btnSettingsTrigger") : btnSettingsTrigger = b1
	btnSettingsTrigger.Text = "☴  ⛃  98%"
	btnSettingsTrigger.TextColor = 0xFFFFFFFF
	pnlTopBar.AddView(btnSettingsTrigger, Root.Width - 120dip, 10dip, 100dip, 30dip)
	Dim joBtn As JavaObject = btnSettingsTrigger
	joBtn.RunMethod("setStyle", Array("-fx-background-radius: 15px; -fx-border-radius: 15px; -fx-border-color: #444444; -fx-cursor: hand;"))
	
	' Main Content Panel Workspace Canvas
	Dim p2 As Pane : p2.Initialize("pnlMain") : pnlMain = p2
	pnlMain.Color = 0xFF1A1A1A
	Root.AddView(pnlMain, 0, topOffset, Root.Width, Root.Height - topOffset)
	
	Dim lblCenter As Label : lblCenter.Initialize("") : Dim bxlCenter As B4XView = lblCenter
	bxlCenter.Text = "Click the top-right tray capsule to test the dropdown drawer."
	bxlCenter.TextColor = 0x44FFFFFF
	pnlMain.AddView(bxlCenter, 40dip, 100dip, 500dip, 40dip)
	
	' Quick Settings Container Overlay Card
	Dim p3 As Pane : p3.Initialize("pnlQuickSettings") : pnlQuickSettings = p3
	pnlQuickSettings.Color = 0xFF242424
	Root.AddView(pnlQuickSettings, Root.Width - panelWidth - 15dip, -panelHeight, panelWidth, panelHeight)
	
	' Injection of critical GNOME theme specs: smooth curves and comprehensive alpha drop shadowing drops
	Dim joPanel As JavaObject = pnlQuickSettings
	joPanel.RunMethod("setStyle", Array("-fx-background-radius: 18px; -fx-border-radius: 18px; -fx-effect: dropshadow(three-pass-box, rgba(0,0,0,0.5), 20, 0, 0, 8);"))
	
	' Pill Toggles (Row 1)
	Dim btnWifi As Button : btnWifi.Initialize("btnWifi") : Dim bxlWifi As B4XView = btnWifi
	bxlWifi.Text = "Wi-Fi: On"
	bxlWifi.Color = 0xFF3584E4
	bxlWifi.TextColor = 0xFFFFFFFF
	pnlQuickSettings.AddView(bxlWifi, 20dip, 20dip, 140dip, 45dip)
	Dim joW As JavaObject = bxlWifi : joW.RunMethod("setStyle", Array("-fx-background-radius: 20px; -fx-cursor: hand;"))
	
	Dim btnBT As Button : btnBT.Initialize("btnBluetooth") : Dim bxlBT As B4XView = btnBT
	bxlBT.Text = "Bluetooth"
	bxlBT.Color = 0xFF3584E4
	bxlBT.TextColor = 0xFFFFFFFF
	pnlQuickSettings.AddView(bxlBT, 180dip, 20dip, 140dip, 45dip)
	Dim joB As JavaObject = bxlBT : joB.RunMethod("setStyle", Array("-fx-background-radius: 20px; -fx-cursor: hand;"))
	
	' Volume Adjustments (Row 2)
	Dim lblVol As Label : lblVol.Initialize("") : Dim bxlVol As B4XView = lblVol
	bxlVol.Text = "🔊 Volume:"
	bxlVol.TextColor = 0xFFFFFFFF
	pnlQuickSettings.AddView(bxlVol, 20dip, 85dip, 80dip, 25dip)
	
	Dim btnVDown As Button : btnVDown.Initialize("btnSliderVolDown") : Dim bxlVD As B4XView = btnVDown
	bxlVD.Text = "-"
	pnlQuickSettings.AddView(bxlVD, 110dip, 85dip, 30dip, 25dip)
	Dim btnVUp As Button : btnVUp.Initialize("btnSliderVolUp") : Dim bxlVU As B4XView = btnVUp
	bxlVU.Text = "+"
	pnlQuickSettings.AddView(bxlVU, 150dip, 85dip, 30dip, 25dip)
	
	Dim lblVVal As Label : lblVVal.Initialize("") : lblVolumePct = lblVVal
	lblVolumePct.TextColor = 0xFFFFFFFF
	pnlQuickSettings.AddView(lblVolumePct, 200dip, 85dip, 50dip, 25dip)
	
	' Notification Feed Setup (Row 3)
	Dim lblNotifHeader As Label : lblNotifHeader.Initialize("") : Dim bxlNH As B4XView = lblNotifHeader
	bxlNH.Text = "Notifications"
	bxlNH.TextColor = 0xAAFFFFFF
	bxlNH.Font = xui.CreateDefaultBoldFont(12)
	pnlQuickSettings.AddView(bxlNH, 20dip, 135dip, 200dip, 20dip)
	
	Dim clv As CustomListView = clvNotifications
	'clv.Initialize(Me, "clvNotifications")
	Dim bxlClv As B4XView = clv.AsView
	pnlQuickSettings.AddView(bxlClv, 15dip, 160dip, panelWidth - 30dip, 240dip)
	clv.sv.Color = 0xFF242424
End Sub