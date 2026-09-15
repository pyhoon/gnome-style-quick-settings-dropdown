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
	
	' Inside Quick Settings Layout Views
	Private clvNotifications As CustomListView ' <-- Linked from your MainPage designer layout
	Private lblVolumePct As B4XView
	
	' State Tracking
	Private isDrawerOpen As Boolean = False
	Private panelWidth As Int = 340dip
	Private panelHeight As Int = 430dip
	Private topOffset As Int = 50dip ' Height of the top bar
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
	Dim targetTop As Int = IIf(isDrawerOpen, topOffset + 5dip, -panelHeight - 50dip)
	
	pnlQuickSettings.SetLayoutAnimated(0, targetLeft, targetTop, panelWidth, panelHeight)
End Sub

' --- INTERACTION LAYER ---

Private Sub btnSettingsTrigger_Click
	Dim targetLeft As Int = Root.Width - panelWidth - 15dip
	
	If isDrawerOpen Then
		pnlQuickSettings.SetLayoutAnimated(220, targetLeft, -panelHeight - 50dip, panelWidth, panelHeight)
		isDrawerOpen = False
		btnSettingsTrigger.Color = 0x00FFFFFF 
	Else
		pnlQuickSettings.BringToFront
		pnlQuickSettings.SetLayoutAnimated(250, targetLeft, topOffset + 5dip, panelWidth, panelHeight)
		isDrawerOpen = True
		btnSettingsTrigger.Color = 0x22FFFFFF 
	End If
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
	
	' GNOME Capsule Style Trigger Button
	Dim b1 As Button
	b1.Initialize("btnSettingsTrigger")
	btnSettingsTrigger = b1
	btnSettingsTrigger.Text = "☴  ⛃  98%"
	btnSettingsTrigger.TextColor = 0xFFFFFFFF
	pnlTopBar.AddView(btnSettingsTrigger, Root.Width - 120dip, 10dip, 100dip, 30dip)
	Dim joBtn As JavaObject = btnSettingsTrigger
	joBtn.RunMethod("setStyle", Array("-fx-background-radius: 15px; -fx-border-radius: 15px; -fx-border-color: #444444; -fx-cursor: hand; -fx-background-color: transparent;"))
	
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
	
	' Quick Settings Container Overlay Card
	Dim p3 As Pane
	p3.Initialize("pnlQuickSettings")
	pnlQuickSettings = p3
	pnlQuickSettings.Color = 0xFF242424
	Root.AddView(pnlQuickSettings, Root.Width - panelWidth - 15dip, -panelHeight - 50dip, panelWidth, panelHeight)
	
	Dim joPanel As JavaObject = pnlQuickSettings
	joPanel.RunMethod("setStyle", Array("-fx-background-radius: 18px; -fx-border-radius: 18px; -fx-effect: dropshadow(three-pass-box, rgba(0,0,0,0.5), 20, 0, 0, 8);"))
	
	' Pill Toggles (Row 1)
	Dim btnWifi As Button
	btnWifi.Initialize("btnWifi")
	Dim bxlWifi As B4XView = btnWifi
	bxlWifi.Text = "Wi-Fi: On"
	pnlQuickSettings.AddView(bxlWifi, 20dip, 20dip, 140dip, 45dip)
	Dim joW As JavaObject = bxlWifi
	joW.RunMethod("setStyle", Array("-fx-background-radius: 20px; -fx-cursor: hand;"))
	bxlWifi.Color = 0xFF3584E4
	bxlWifi.TextColor = 0xFFFFFFFF
		
	Dim btnBT As Button
	btnBT.Initialize("btnBluetooth")
	Dim bxlBT As B4XView = btnBT
	bxlBT.Text = "Bluetooth"
	pnlQuickSettings.AddView(bxlBT, 180dip, 20dip, 140dip, 45dip)
	Dim joB As JavaObject = bxlBT
	joB.RunMethod("setStyle", Array("-fx-background-radius: 20px; -fx-cursor: hand;"))
	bxlBT.Color = 0xFF363636
	bxlBT.TextColor = 0xFFFFFFFF
		
	' Volume Adjustments (Row 2)
	Dim lblVol As Label
	lblVol.Initialize("")
	Dim bxlVol As B4XView = lblVol
	bxlVol.Text = "🔊 Volume:"
	bxlVol.TextColor = 0xFFFFFFFF
	pnlQuickSettings.AddView(bxlVol, 20dip, 85dip, 80dip, 25dip)
	
	Dim btnVDown As Button
	btnVDown.Initialize("btnSliderVolDown")
	Dim bxlVD As B4XView = btnVDown
	bxlVD.Text = "-"
	pnlQuickSettings.AddView(bxlVD, 110dip, 85dip, 30dip, 25dip)
	Dim btnVUp As Button
	btnVUp.Initialize("btnSliderVolUp")
	Dim bxlVU As B4XView = btnVUp
	bxlVU.Text = "+"
	pnlQuickSettings.AddView(bxlVU, 150dip, 85dip, 30dip, 25dip)
	
	Dim lblVVal As Label
	lblVVal.Initialize("")
	lblVolumePct = lblVVal
	lblVolumePct.TextColor = 0xFFFFFFFF
	pnlQuickSettings.AddView(lblVolumePct, 200dip, 85dip, 50dip, 25dip)
	
	' Notification Feed Setup (Row 3)
	Dim lblNotifHeader As Label
	lblNotifHeader.Initialize("")
	Dim bxlNH As B4XView = lblNotifHeader
	bxlNH.Text = "Notifications"
	bxlNH.TextColor = 0xAAFFFFFF
	bxlNH.Font = xui.CreateDefaultBoldFont(12)
	pnlQuickSettings.AddView(bxlNH, 20dip, 135dip, 200dip, 20dip)
	
	' FIXED: Do NOT initialize clvNotifications. It's already built by Root.LoadLayout!
	' Instead, we fetch its Base View panel and target its position inside the card wrapper.
	Dim clvBasePanel As B4XView = clvNotifications.GetBase
	
	' Remove it from the root layout layer and nest it safely inside our floating drawer card instead
	clvBasePanel.RemoveViewFromParent
	pnlQuickSettings.AddView(clvBasePanel, 15dip, 160dip, panelWidth - 30dip, 240dip)
	
	clvNotifications.sv.Color = 0xFF242424
	CallSubDelayed3(Me, "SetScrollPaneBackgroundColor", clvNotifications, xui.Color_Transparent)
	
	StyleCustomScrollbar(clvNotifications)
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
	
	' 2. Resize the CLV View base layout wrapper panel safely inside the drawer card
	Dim clvBase As B4XView = clvNotifications.GetBase
	clvBase.SetLayoutAnimated(0, clvBase.Left, clvBase.Top, clvBase.Width, targetClvHeight)
	clvNotifications.Base_Resize(clvBase.Width, targetClvHeight) ' Forces internal Scrollview content rebuild
	
	' 3. Calculate new total height for the outer GNOME drawer panel container
	panelHeight = 160dip + targetClvHeight + 20dip
	
	' 4. Instantly shift or anchor the panel location based on state
	Dim targetLeft As Int = Root.Width - panelWidth - 15dip
	If isDrawerOpen Then
		pnlQuickSettings.SetLayoutAnimated(0, targetLeft, topOffset + 5dip, panelWidth, panelHeight)
	Else
		pnlQuickSettings.SetLayoutAnimated(0, targetLeft, -panelHeight - 50dip, panelWidth, panelHeight)
	End If
	
	pnlQuickSettings.BringToFront
End Sub