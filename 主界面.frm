VERSION 5.00
Begin VB.Form Form1 
   BorderStyle     =   0  'None
   Caption         =   "ȫ��ϵͳ����"
   ClientHeight    =   2235
   ClientLeft      =   -45
   ClientTop       =   -375
   ClientWidth     =   2595
   BeginProperty Font 
      Name            =   "����"
      Size            =   12
      Charset         =   134
      Weight          =   400
      Underline       =   0   'False
      Italic          =   0   'False
      Strikethrough   =   0   'False
   EndProperty
   LinkTopic       =   "Form1"
   MaxButton       =   0   'False
   MinButton       =   0   'False
   ScaleHeight     =   2235
   ScaleWidth      =   2595
   ShowInTaskbar   =   0   'False
   Begin VB.Timer Timer1 
      Enabled         =   0   'False
      Interval        =   10
      Left            =   240
      Top             =   1440
   End
   Begin VB.Timer TimRun 
      Enabled         =   0   'False
      Interval        =   1000
      Left            =   1680
      Top             =   1440
   End
   Begin VB.Timer TimHandle 
      Enabled         =   0   'False
      Interval        =   100
      Left            =   960
      Top             =   1440
   End
   Begin VB.CommandButton cmdRun 
      BackColor       =   &H00FFFFFF&
      Caption         =   "��ʼ"
      Enabled         =   0   'False
      Height          =   480
      Left            =   240
      TabIndex        =   0
      Top             =   360
      Width           =   2040
   End
End
Attribute VB_Name = "Form1"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False

Private Declare Sub SetWindowPos _
                Lib "user32" (ByVal hwnd As Long, _
                              ByVal hWndInsertAfter As Long, _
                              ByVal X As Long, _
                              ByVal Y As Long, _
                              ByVal cx As Long, _
                              ByVal cy As Long, _
                              ByVal wFlags As Long)

Private Declare Function GetTickCount Lib "kernel32" () As Long

Private Declare Function ShowWindow _
                Lib "user32" (ByVal hwnd As Long, _
                              ByVal nCmdShow As Long) As Long

Private Declare Sub Sleep Lib "kernel32" (ByVal dwMilliseconds As Long)

Private Const HWND_TOPMOST = -1

Private Const SW_HIDE = 0 '���ش���

Private Const SW_SHOW = 5 '��ʾ����

Private Const HWND_NOTOPMOST = -2

Private Const SWP_NOSIZE = &H1

Private Const SWP_NOMOVE = &H2

Private Const SWP_NOACTIVATE = &H10

Private Const SWP_SHOWWINDOW = &H40

Private Declare Function FindWindow _
                Lib "user32" _
                Alias "FindWindowA" (ByVal lpClassName As String, _
                                     ByVal lpWindowName As String) As Long

Private Declare Function FindWindowEx _
                Lib "user32" _
                Alias "FindWindowExA" (ByVal hWnd1 As Long, _
                                       ByVal hWnd2 As Long, _
                                       ByVal lpsz1 As String, _
                                       ByVal lpsz2 As String) As Long

Private Declare Function SendMessage _
                Lib "user32" _
                Alias "SendMessageA" (ByVal hwnd As Long, _
                                      ByVal wMsg As Long, _
                                      ByVal wParam As Long, _
                                      lParam As Any) As Long

Private Declare Function SetActiveWindow Lib "user32" (ByVal hwnd As Long) As Long

Private Const BM_CLICK As Long = &HF5

Private Declare Function PostMessage _
                Lib "user32" _
                Alias "PostMessageA" (ByVal hwnd As Long, _
                                      ByVal wMsg As Long, _
                                      ByVal wParam As Long, _
                                      ByVal lParam As Long) As Long

Private Const WM_LBUTTONDOWN = &H201 '�������

Private Const WM_LBUTTONUP = &H202 '�������

Private Const WM_CLOSE As Long = &H10&

Dim n                  As Long '����ʱ����

Dim windowHandle       As Long '������

Dim buttonHandle       As Long '��ť���

Dim popwindowsHandle   As Long '�������ھ��

Dim windowName         As String '��������

Dim popwindowName      As String '������������

Dim buttonName         As String '��ť����

Dim exePach            As String '����������·��

Dim formLeft           As Long '��¼����λ��

Dim formtop            As Long

Dim intTime            As Integer

Dim onTop              As Boolean '�����Ƿ��ö�

'�϶��ޱ߿���
Private Declare Function ReleaseCapture Lib "user32" () As Long

Private Declare Function ReleaseDC _
                Lib "user32" (ByVal hwnd As Long, _
                              ByVal hdc As Long) As Long

Const WM_NCLBUTTONDOWN = &HA1

Const HTCAPTION = 2

Private Sub Form_MouseMove(Button As Integer, Shift As Integer, X As Single, Y As Single)

    If Button = 1 Then
        Call ReleaseCapture
        Call SendMessage(Me.hwnd, WM_NCLBUTTONDOWN, HTCAPTION, 0&)

    End If

End Sub

Private Sub cmdRun_Click()

    If FindwindowHandle(windowName) > 0 Then
        ' ShowWindow windowHandle, SW_SHOW '�ָ�����
 
        If FindpopwindowHandle(popwindowName) > 0 Then '�����ť�󵯳��˶Ի���
      
            SendMessage popwindowsHandle, WM_CLOSE, 0&, 0& '�رմ���
            '������Ϣ�رմ���

        End If
                
        cmdRun.Enabled = True
    Else
        cmdRun.Enabled = fasle
        cmdRun.Caption = "��ʼ"
        TimHandle.Enabled = True '��������

    End If

    Select Case cmdRun.Caption

        Case "��ʼ"

            If cmdRun.Enabled = False Then
                cmdRun.Caption = "��ʼ"
                Form1.BackColor = vbWhite
            Else
                cmdRun.Caption = "ֹͣ"
                TimRun.Enabled = True '�������
                Form1.BackColor = vbGreen

            End If

            If FindwindowHandle(windowName) > 0 Then
                ' ShowWindow windowHandle, SW_HIDE '���ش���

            End If
           
        Case "ֹͣ"
            TimRun.Enabled = False 'ֹͣ���
            cmdRun.Caption = "��ʼ"
            Form1.BackColor = vbRed

    End Select

End Sub

Private Sub Form_Load()

    If App.LogMode Then SetWindowIcon Me.hwnd, "AAA"
    '��ȡini����
    mdlIni.FileName = Replace(App.Path + "\", "\\", "\") + "set.ini" '����ini·��
    onTop = mdlIni.ReadData("set", "onTop", 1) '�Ƿ��ö�
    intTime = mdlIni.ReadData("set", "Time", 1)

    If onTop = True Then
        SetWindowPos Me.hwnd, IIf(onTop, -1, -2), 0, 0, 0, 0, SWP_NOACTIVATE Or SWP_SHOWWINDOW Or SWP_NOMOVE Or SWP_NOSIZE

        '�ö�
    End If

    formLeft = mdlIni.ReadData("set", "Left", (Screen.Width - Me.Width) / 2)
    formtop = mdlIni.ReadData("set", "Top", (Screen.Height - Me.ScaleHeight) / 2)
    
    Move formLeft, formtop '�ƶ����嵽ָ��λ��
    
    windowName = mdlIni.ReadData("set", "windowName", "����ҽ������վ(ȫ������)")
    popwindowName = mdlIni.ReadData("set", "popwindowName", "ѡȡ����")
    buttonName = mdlIni.ReadData("set", "buttonName", "ѡ����")
    exePach = mdlIni.ReadData("set", "exePach", "")

    If exePach <> "" And FindwindowHandle(windowName) <= 0 Then  '���������·��,���ҳ���û�������Ļ�.
        Set oShell = CreateObject("WSCript.shell")
        ' oShell.run "cmd /C " & exePach & sCommand, 0, True  ' wintWindowStyle = 0, so cmd will be hidden
        oShell.run "cmd /C " & exePach, 0, True   ' wintWindowStyle = 0, so cmd will be hidden
        ' Shell �������� ���ҵȴ���������
        
    End If
    
    TimHandle.Enabled = True  ' �������������򴰿ڹ���

End Sub

Private Function FindwindowHandle(winName As String) As Long '���������ھ��
    ' winName = windowName
    FindwindowHandle = FindWindow("FNWND390", winName)
   
    windowHandle = FindwindowHandle

End Function

Private Function FindbuttonHandle(bonName As String) As Long '���Ұ�ť���

    On Error Resume Next

    Dim WinWnd As Long

    Dim Ret    As Long

    Dim ErrNum As Integer
    
    'Find window Handle
    WinWnd = FindWindow("FNWND390", windowName)
    
    If WinWnd <> 0 Then
        'Show the form
        'AppActivate "email poster"
        'Find button handle by going through every child control in the form
        EnumChildWindows WinWnd, AddressOf EnumChildProc, ByVal 0&
        
        If BtnHwnd <> 0 Then
            FindbuttonHandle = BtnHwnd
            BtnHwnd = 0

        End If

    End If

    buttonHandle = FindbuttonHandle

End Function

Private Function FindpopwindowHandle(popwinName As String) As Long '���ҵ������ھ��

    'popwindowName = popwinName
    '��������������
    FindpopwindowHandle = FindWindowLike(0, popwinName, "FNWNS390")
    
    ' FindpopwindowHandle = FindWindow("FNWNS390", popwinName)
    Debug.Print FindpopwindowHandle
    '����: Dim hLastWin as Long
    '      hLastWin = MyFindWindow()

    popwindowsHandle = FindpopwindowHandle

End Function

Private Sub Form_MouseUp(Button As Integer, Shift As Integer, X As Single, Y As Single)

    If Button = vbRightButton Then

        ' PopupMenu MNUexit
        If MsgBox("��:�˳�,��:���˳�", vbOKCancel, "�˳�") = vbOK Then
            Unload Me
        Else

        End If

    End If
    
End Sub

Private Sub Form_Unload(Cancel As Integer)

    If FindwindowHandle(windowName) > 0 Then
        ShowWindow windowHandle, SW_SHOW '�ָ�����
 
        If FindpopwindowHandle(popwindowName) > 0 Then '�����ť�󵯳��˶Ի���
      
            SendMessage popwindowsHandle, WM_CLOSE, 0&, 0& '�رմ���
            '������Ϣ�رմ���

        End If

    End If

    mdlIni.WriteData "set", "Left", Me.Left
    mdlIni.WriteData "set", "Top", Me.Top
 
End Sub

Private Sub subExit_Click()
    Unload Me

End Sub

Private Sub Timer1_Timer()
    Timer1.Enabled = False

    If buttonHandle > 0 Then
        If FindpopwindowHandle(popwindowName) > 0 Then  '�����ť�󵯳��˶Ի���
            ' SetActiveWindow popwindowsHandle
            'hwnd Ϊ��Ҫ�رյĴ��ڳ���Ĵ��ھ����
            ' ShowWindow popwindowsHandle, SW_HIDE
            'SetWindowPos popwindowsHandle, 1, 0, 0, 0, 0, SWP_NOACTIVATE Or SWP_SHOWWINDOW Or SWP_NOMOVE Or SWP_NOSIZE '�ú�
            'SetWindowPos popwindowsHandle, -2, 0, 0, 0, 0, SWP_NOACTIVATE Or SWP_SHOWWINDOW Or SWP_NOMOVE Or SWP_NOSIZE '������ʾ
            SendMessage popwindowsHandle, WM_CLOSE, 0&, 0& '�رմ���
            '���͵���Ϣ����������ѡ��1��wMsgΪWM_CLOSE��wParam��lParamΪ0��2��wMsgΪWM_SYSCOMMAND��wParamΪCS_CLOSE��lParamΪ0��
     
            '������Ϣ�رմ���1
            TimRun.Enabled = True

        End If

    End If

End Sub

Private Sub TimHandle_Timer() '�����������Ƿ����� '
 
    If FindwindowHandle(windowName) > 0 Then
        TimHandle.Enabled = False  'ֹͣ����.
        Debug.Print "�������Ѿ�����"
        cmdRun.Enabled = True '��ʼ��ť����
        'ShowWindow windowHandle, SW_HIDE
    Else
        cmdRun.Enabled = False '��ʼ��ť������

    End If
  
End Sub

Private Sub TimRun_Timer() '����
    n = n + 1000 '

    If n >= intTime * 30000 Then '�����
       
        If FindpopwindowHandle(popwindowName) > 0 Then '�����ť�󵯳��˶Ի���
      
            SendMessage popwindowsHandle, WM_CLOSE, 0&, 0& '�رմ���
            '������Ϣ�رմ���

        End If

        '�ҵ���ť���
        If FindbuttonHandle(buttonName) > 0 Then
            SendMessage buttonHandle, BM_CLICK, 0, 0
            'sedmessage '���Ͱ��������ť
            '        SetActiveWindow windowHandle
            '        PostMessage buttonHandle, WM_LBUTTONDOWN, 0, 0
            '        PostMessage buttonHandle, WM_LBUTTONUP, 0, 0
            '�ȴ� ���ڵ���
            ' SendClick buttonHandle, 130, 60
            Delay 3000
      
            Timer1.Enabled = True
            TimRun.Enabled = False
            n = 0
        Else
            TimRun.Enabled = False
            TimHandle.Enabled = True '����
      
        End If
          
    End If

End Sub

Public Function SendClick(hwnd As Long, mX As Long, mY As Long)

    Dim i As Long
      
    i = PostMessage(hwnd, WM_LBUTTONDOWN, 0, (mX And &HFFFF) + (mY And &HFFFF) * &H10000)
 
    i = PostMessage(hwnd, WM_LBUTTONUP, 0, (mX And &HFFFF) + (mY And &HFFFF) * &H10000)

End Function

Private Sub Delay(Msec As Long)

    Dim EndTime As Long

    EndTime = GetTickCount + Msec
    Do
        Sleep 1
        DoEvents
    Loop While GetTickCount < EndTime

End Sub
