Attribute VB_Name = "modGlobal"
Option Explicit

Private Type tagInitCommonControlsEx
   lngSize As Long
   lngICC As Long
End Type

Private Declare Function InitCommonControlsEx Lib "comctl32.dll" _
   (iccex As tagInitCommonControlsEx) As Boolean
Private Const ICC_USEREX_CLASSES = &H200

Private Const ECM_FIRST As Long = &H1500
Private Const EM_SETCUEBANNER As Long = (ECM_FIRST + 1)

Private Declare Function SendMessage Lib "user32" Alias "SendMessageA" ( _
    ByVal hWnd As Long, _
    ByVal wMsg As Long, _
    ByVal wParam As Long, _
    lParam As Any) As Long

Public Const MOVIMIENTO_ENTRADA As String = "E"
Public Const MOVIMIENTO_SALIDA  As String = "S"

Public Enum EListas
    lsProductos
    lsRubros
    lsMovimientos
End Enum

Public Enum EModalResult
    mrCancel
    mrOK
End Enum

Public gPathINI As String
Public gAppName As String

Public Function InitCommonControlsVB() As Boolean
   On Error Resume Next
   Dim iccex As tagInitCommonControlsEx
   ' Ensure CC available:
   With iccex
       .lngSize = LenB(iccex)
       .lngICC = ICC_USEREX_CLASSES
   End With
   InitCommonControlsEx iccex
   InitCommonControlsVB = (Err.Number = 0)
   On Error GoTo 0
End Function

Public Sub Main()
    InitCommonControlsVB
    
    gAppName = App.Title & " v" & App.Major & "." & App.Minor & "." & Format$(App.Revision, "00")
    gPathINI = App.Path & "\config.ini"
    
    If InitConnection() Then
        With New frmLogin
            If .ShowModal = vbOK Then
                frmPrincipal.Show
            End If
        End With
    End If
End Sub

Public Function ToNumber(ByVal Value As String) As Double
    On Error Resume Next
    ToNumber = Val(Replace(Value, Format$(0, "."), "."))
End Function

Public Function ToDate(ByVal Value As String) As Double
    On Error Resume Next
    If Not IsDate(Value) Then
        ToDate = Now
    Else
        ToDate = CDate(Value)
    End If
End Function

Public Function Confirm(ByVal Message As String, _
                        ByVal Title As String, _
                        Optional ByVal Warning As Boolean = False, _
                        Optional ByVal YesIsDefault As Boolean = True) As Boolean
    Dim BoxStyle As VbMsgBoxStyle
    
    BoxStyle = vbYesNo
    
    If Warning Then
        BoxStyle = BoxStyle + vbExclamation
    Else
        BoxStyle = BoxStyle + vbInformation
    End If
    
    If Not YesIsDefault Then
        BoxStyle = BoxStyle + vbDefaultButton2
    End If
    
    If MsgBox(Message, BoxStyle, Title) = vbYes Then
        Confirm = True
    Else
        Confirm = False
    End If
End Function

Public Function ExistFile(ByVal FilePath As String) As Boolean
    If FilePath = vbNullString Then
        ExistFile = False
    Else
        ExistFile = Len(Dir(FilePath)) <> 0
    End If
End Function

Public Sub ErrorReport(ByVal ModuleName As String, _
                       ByVal ProcedureName As String, _
                       Optional ByVal OptionalMessage As String = vbNullString, _
                       Optional ByVal ShowError As Boolean = True)
    Dim msg As String
    
    If ShowError Then
        msg = Err.Description
        
        If Len(OptionalMessage) Then
            msg = msg & vbCrLf & vbCrLf & OptionalMessage
        End If
        
        MsgBox msg, vbCritical, "Error n� " & Format$(Err.Number)
    End If
End Sub

Public Sub HLText(ByRef TheObject As Object)
    On Error Resume Next
    With TheObject
        .SelStart = 0
        .SelLength = Len(.Text)
    End With
End Sub

Public Function IsEven(ByVal Number As Integer) As Boolean
    IsEven = (Number Mod 2 = 0)
End Function

Public Function FindInStringArray(ByRef Arr() As String, _
                                  ByVal Value As Variant) As Long
    Dim i As Long

    FindInStringArray = -1
    
    For i = 0 To UBound(Arr)
        If Arr(i) = Value Then FindInStringArray = i: Exit For
    Next
End Function

Public Function StrFormat(ByVal TheString As String, _
                             ParamArray Arguments() As Variant) As String
    
    Dim i As Long

    For i = 0 To UBound(Arguments)
        TheString = Replace(TheString, "{" & Trim$(str$(i + 1)) & "}", Arguments(i))
    Next
    
    StrFormat = TheString
End Function

Public Sub EnabledForm(ByRef frm As Form, ByVal Value As Boolean)
    Dim ctl As Control
    
    For Each ctl In frm.Controls
        If TypeOf ctl Is TextBox _
        Or TypeOf ctl Is CommandButton _
        Or TypeOf ctl Is ComboBox _
        Or TypeOf ctl Is ListBox _
        Or TypeOf ctl Is OptionButton _
        Or TypeOf ctl Is CheckBox _
        Or TypeOf ctl Is MaskEdBox Then
            ctl.Enabled = Value
        End If
    Next
End Sub

Public Sub EnabledTextBox(ByVal ctl As Object, ByVal Value As Boolean)
    ctl.Locked = Not Value
    
    If Not Value Then
        ctl.BackColor = vbButtonFace
    Else
        ctl.BackColor = vbWindowBackground
    End If
End Sub

Public Function OpenTextFile(ByVal FileName As String) As String
    Dim FileNumber As Long
    
    On Error GoTo ErrorHandler
    
    FileNumber = FreeFile()
    
    Open FileName For Input As #FileNumber
    
    OpenTextFile = StrConv(InputB(LOF(FileNumber), FileNumber), vbUnicode)
    
    Close #FileNumber

    Exit Function
ErrorHandler:
    MsgBox "No se puede abrir el archivo: " & FileName, vbCritical, "Error"
End Function

Public Function FormatDecimal(ByVal Value As String) As String
    FormatDecimal = Format$(ToNumber(Value), "#0.00")
End Function

Public Function GetItemData(ByRef cbo As ComboBox, _
                            Optional ByVal Default As Long = -1) As Long
    On Error Resume Next
    With cbo
        If .ListIndex <> -1 Then
            GetItemData = .ItemData(.ListIndex)
        Else
            GetItemData = Default
        End If
    End With
End Function

Public Sub SetItemData(ByRef cbo As ComboBox, _
                       ByVal Value As Long, _
                       Optional ByVal Default As Long = -1)
    Dim i As Long
    
    With cbo
        For i = 0 To .ListCount - 1
            If .ItemData(i) = Value Then
                .ListIndex = i
                Exit For
            End If
        Next

        If i = .ListCount Then
            .ListIndex = Default
        End If
    End With
End Sub

Public Sub SetCueBanner(ByRef TextBox As TextBox, ByVal Banner As String)
    Dim s As String
    
    s = StrConv(Banner, vbUnicode)
    Call SendMessage(TextBox.hWnd, EM_SETCUEBANNER, 0&, ByVal s)
End Sub

