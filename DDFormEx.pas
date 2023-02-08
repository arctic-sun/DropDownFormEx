{
  ---------------------------
  DDFormEx - Based on DropingDown Forms source code from eh.Lib by D.V. Bo1shakov
  ---------------------------
}

unit DDFormEx;

{$I DDFE.inc}

interface

uses
  Messages,
  Windows,
  UxTheme,
  MultiMon,
  Types,
  Themes,
{$IFDEF VVX17} System.UITypes, {$ENDIF}
  SysUtils,
  Classes,
  Graphics,
  Controls,
  Forms,
  Buttons,
  Vcl.StdCtrls,
  ExtCtrls;

type
  TDDFormEx = class;
  TDDFormResizeBar = class;
  TDDLayout = (ddlAboveControl, ddlUnderControl);
  TDDFormExElementItem = (ddfeLeftGrip, ddfeRightGrip, ddfeCloseButton, ddfeSizingBar);
  TDDFormExElements = set of TDDFormExElementItem;

  TDDAlign = (ddLeft, ddRight, ddCenter);

  TInitDDFormExEvent = procedure(Sender: TDDFormEx) of object;

  { TDDFormResizeBarSizeGrip }
  TSZGripPosition = (szgpTopLeft, szgpTopRight, szgpBottomRight, szgpBottomLeft);
  TSZGripChangePosition = (szgcpToLeft, szgcpToRight, szgcpToTop, szgcpToBottom);

  TDDFormResizeBarSizeGrip = class(TCustomControl)
  private
    FInitScreenMousePos: TPoint;
    FInternalMove: Boolean;
    FOldMouseMovePos: TPoint;
    FParentRect: TRect;
    FParentResized: TNotifyEvent;
    FPosition: TSZGripPosition;
    FTriangleWindow: Boolean;
    FHostControl: TWinControl;
    function GetHostControl: TWinControl;
    function GetVisible: Boolean;
    procedure SetPosition(const Value: TSZGripPosition);
    procedure SetTriangleWindow(const Value: Boolean);
    procedure SetHostControl(const Value: TWinControl);
    procedure SetVisible(const Value: Boolean);
  protected
    procedure CreateHandle; override;
    procedure CreateWnd; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
    procedure ParentResized; dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    procedure ChangePosition(NewPosition: TSZGripChangePosition);
    procedure UpdatePosition;
    procedure UpdateWindowRegion;
    property HostControl: TWinControl read GetHostControl write SetHostControl;
    property Position: TSZGripPosition read FPosition write SetPosition default szgpBottomRight;
    property TriangleWindow: Boolean read FTriangleWindow write SetTriangleWindow default True;
    property Visible: Boolean read GetVisible write SetVisible;
    property OnParentResized: TNotifyEvent read FParentResized write FParentResized;
  end;


  { TDDFormEx }
  TDDFormEx = class(TForm)
  private
    FBorderWidth: Integer;
    FDropDownMode: Boolean;
    FFormElements: TDDFormExElements;
    FKeepFormVisible: Boolean;
    FOnInitForm: TInitDDFormExEvent;
    FReadOnly: Boolean;
    FSizeGrip: TDDFormResizeBarSizeGrip;
    FSizeGrip2: TDDFormResizeBarSizeGrip;
    function GetBorderStyle: TFormBorderStyle;
    function GetControlClientRect: TRect;
    function GetReadOnly: Boolean;
    procedure SetDropDownMode(const Value: Boolean);
    procedure SetReadOnly(const Value: Boolean);
    procedure WMActivate(var msg: TWMActivate); message WM_ACTIVATE;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
    procedure SetKeepFormVisible(const Value: Boolean);
    procedure CloseClick(Sender: TObject );
  protected
    FActivateClosing: Boolean;
    FActivateShowing: Boolean;
    FCloseButton: TButton;
    FDropLayout: TDDLayout;
    FMasterFocusControl: TWinControl;
    FMasterForm: TCustomForm;
    FModalMode: Boolean;
    FSizingBar: TDDFormResizeBar;
    FClosing: Boolean;

    function DoHandleStyleMessage(var Message: TMessage): Boolean; {$IFDEF VVX16} override; {$ENDIF}

{$IFDEF VVX14}
    procedure GetBorderStyles(var Style, ExStyle, ClassStyle: Cardinal); override;
{$ENDIF}
    procedure AdjustClientRect(var aRect: TRect); override;
    procedure CreateHandle; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DoClose(var Action: TCloseAction); override;
    procedure DoHide; override;
    procedure DrawBorder(BorderRect: TRect); virtual;
    procedure InitializeNewForm; {$IFDEF VVX12} override; {$else} virtual; {$ENDIF}
    procedure Loaded; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    constructor CreateNew(AOwner: TComponent; Dummy: Integer = 0); override;
    destructor Destroy; override;

    function Execute(RelativePosControl: TControl; DownStateControl: TControl; Align: TDDAlign): Boolean; virtual;
    function ShowModal: Integer; override;

    procedure ExecuteNomodal(RelativePosRect: TRect; DownStateControl: TControl; Align: TDDAlign);
    procedure InitElements; virtual;
    procedure InitForm(Host: TComponent); virtual;
    procedure Show;
    procedure Close;
    procedure UpdateSize; virtual;

    class function GetGlobalRef: TDDFormEx; virtual;

    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    property KeepFormVisible: Boolean read FKeepFormVisible write SetKeepFormVisible;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly;
    property ControlClientRect: TRect read GetControlClientRect;

  published
    property FormElements: TDDFormExElements read FFormElements write FFormElements default [ddfeLeftGrip, ddfeRightGrip, ddfeCloseButton, ddfeSizingBar];
    property BorderStyle: TFormBorderStyle read GetBorderStyle stored False;
    property DropDownMode: Boolean read FDropDownMode write SetDropDownMode;
    property OnInitForm: TInitDDFormExEvent read FOnInitForm write FOnInitForm;
  end;


  { TDDFormResizeBar }
  TDDFormResizeBar = class(TCustomPanel)
  private
    FHostControl: TWinControl;
    FMouseDownPos: TPoint;
    FSizingArea: Integer;
    procedure WMSetCursor(var Msg: TWMSetCursor); message WM_SETCURSOR;
  protected
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property HostControl: TWinControl read FHostControl write FHostControl;
  end;


   function ClientToScreenRect(Control: TControl): TRect;

implementation


function WindowsCreatePolygonRgn(Points: array of TPoint; Count, FillMode: Integer): HRGN;
begin
  Result := CreatePolygonRgn(Points, Count, FillMode);
end;

type
  TWinControlCrack = class(TWinControl);

function GetAdjustedClientRect(Control: TWinControl): TRect;
begin
  if (Control.HandleAllocated) then
    Result := Control.ClientRect
  else
    Result := Rect(0, 0, Control.Width, Control.Height);

  TWinControlCrack(Control).AdjustClientRect(Result);
end;

procedure RegisterClasses;
begin
  NewStyleControls := True;
  RegisterClass(TDDFormResizeBarSizeGrip);
  RegisterClass(TDDFormEx);
end;

function ClientToScreenRect(Control: TControl): TRect;
begin
  Result.TopLeft := Control.ClientToScreen(Point(0,0));
  Result.Bottom := Result.Top + Control.Height;
  Result.Right := Result.Left + Control.Width;
end;

function CustomStyleActive: Boolean;
begin
{$IFDEF VVX16} //XE2
  Result := TStyleManager.IsCustomStyleActive;
{$ELSE}
  Result := False;
{$ENDIF}
end;

function ThemesEnabled: Boolean;
begin
  Result := ThemeServices.ThemesEnabled;
end;

procedure UnregisterClasses;
begin
  UnregisterClass(TDDFormEx);
end;

function AdjustDropDownForm(AControl: TControl; HostRect: TRect; Align: TDDAlign): TDDLayout;
var
  WorkArea: TRect;
  HostP: TPoint;
  MonInfo: TMonitorInfo;
begin

  Result := ddlUnderControl;

  MonInfo.cbSize := SizeOf(MonInfo);
{$IFDEF CIL}
  GetMonitorInfo(MonitorFromRect(HostRect, MONITOR_DEFAULTTONEAREST), MonInfo);
{$ELSE}
  GetMonitorInfo(MonitorFromRect(@HostRect, MONITOR_DEFAULTTONEAREST), @MonInfo);
{$ENDIF}

  WorkArea := MonInfo.rcWork;


  HostP := HostRect.TopLeft;

  AControl.Left := HostP.x;
  AControl.Top := HostP.y + (HostRect.Bottom - HostRect.Top) + 1;

  case Align of
    ddRight: AControl.Left := AControl.Left - (AControl.Width - (HostRect.Right - HostRect.Left) );
    ddCenter: AControl.Left := AControl.Left - ((AControl.Width - (HostRect.Right - HostRect.Left)) div 2);
  end;

  if (AControl.Width > WorkArea.Right - WorkArea.Left) then
    AControl.Width := WorkArea.Right - WorkArea.Left;

  if (AControl.Left + AControl.Width > WorkArea.Right) then
    AControl.Left := WorkArea.Right - AControl.Width;
  if (AControl.Left < WorkArea.Left) then
    AControl.Left := WorkArea.Left;

  if (AControl.Top + AControl.Height > WorkArea.Bottom) then
  begin
    if (HostP.y - WorkArea.Top > WorkArea.Bottom - HostP.y - (HostRect.Bottom - HostRect.Top)) then
    begin
      Result := ddlAboveControl;
      AControl.Top := HostP.y - AControl.Height;
    end;
  end;

  if (AControl.Top < WorkArea.Top) then
  begin
    AControl.Height := AControl.Height - (WorkArea.Top - AControl.Top);
    AControl.Top := WorkArea.Top;
  end;
  if (AControl.Top + AControl.Height > WorkArea.Bottom) then
  begin
    AControl.Height := WorkArea.Bottom - AControl.Top;
  end;
end;

constructor TDDFormEx.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDropDownMode := True;
  inherited BorderStyle := bsNone;
  if (Constraints.MinWidth = 0) then
    Constraints.MinWidth := GetSystemMetrics(SM_CXVSCROLL) * 2;
  if (Constraints.MinHeight = 0) then
    Constraints.MinHeight := GetSystemMetrics(SM_CYVSCROLL) * 2;
  Position := poDesigned;
end;

constructor TDDFormEx.CreateNew(AOwner: TComponent; Dummy: Integer = 0);
begin
  inherited CreateNew(AOwner);
{$IFNDEF VVX12}
  InitializeNewForm;
{$ENDIF}
end;

destructor TDDFormEx.Destroy;
begin
  FreeAndNil(FCloseButton);
  FreeAndNil(FSizingBar);
  FreeAndNil(FSizeGrip);
  FreeAndNil(FSizeGrip2);
  inherited Destroy;
end;

procedure TDDFormEx.CloseClick(Sender: TObject );
begin
  Self.Close;
end;

procedure TDDFormEx.InitializeNewForm;
begin
{$IFDEF VVX12}
  inherited InitializeNewForm;
{$ENDIF}

  FCloseButton := TButton.Create(nil);

  FCloseButton.Caption := 'X';

  FCloseButton.Width := 32;
  FCloseButton.OnClick := CloseClick;


  FCloseButton.Parent := Self;
  FCloseButton.Visible := False;

  FSizingBar := TDDFormResizeBar.Create(nil);
  FSizingBar.Parent := Self;
  FSizingBar.Visible := False;
  FSizingBar.HostControl := Self;

  FSizeGrip := TDDFormResizeBarSizeGrip.Create(nil);
  FSizeGrip.HostControl := Self;
  FSizeGrip.TriangleWindow := True;
  FSizeGrip.Visible := False;

  FSizeGrip2 := TDDFormResizeBarSizeGrip.Create(nil);
  FSizeGrip2.HostControl := Self;
  FSizeGrip2.TriangleWindow := True;
  FSizeGrip2.Position := szgpBottomLeft;
  FSizeGrip2.Visible := False;

  FCloseButton.Anchors := [akTop, akRight];
  FFormElements := [ddfeLeftGrip, ddfeRightGrip, ddfeCloseButton, ddfeSizingBar];
  BorderIcons := [];
  inherited BorderStyle := bsNone;
  FDropDownMode := True;

  if CheckWin32Version(10, 0) then
    FBorderWidth := 1
  else if CheckWin32Version(6, 0) then
    FBorderWidth := 3
  else
    FBorderWidth := 2;

  Constraints.MinWidth := GetSystemMetrics(SM_CXVSCROLL) * 2;
  Constraints.MinHeight := GetSystemMetrics(SM_CYVSCROLL) * 2;
  Position := poDesigned;
  FormStyle := fsStayOnTop;
end;

function TDDFormEx.Execute(RelativePosControl: TControl; DownStateControl: TControl; Align: TDDAlign): Boolean;
var
  SelfPos, RelPos: TPoint;
begin
  FModalMode := True;

  if Visible then
    Visible := False;

  FDropLayout := AdjustDropDownForm(Self, ClientToScreenRect(RelativePosControl), Align);
  SelfPos := Self.ClientToScreen(Point(0,0));
  RelPos := RelativePosControl.ClientToScreen(Point(0,0));
  if SelfPos.Y < RelPos.Y then
  begin
    FSizeGrip.Position := szgpTopRight;
    FSizeGrip2.Position := szgpTopLeft;
  end else
  begin
    FSizeGrip.Position := szgpBottomRight;
    FSizeGrip2.Position := szgpBottomLeft;
  end;

  InitElements; // <- Test
  InitForm(nil);

  ModalResult := mrNone;
  Visible := True;

  while Active and (ModalResult = mrNone) do
    Application.HandleMessage;

  Visible := False;
  Result := False;
  if ModalResult = mrOk then
  begin
    Result := True;
  end;
end;

procedure TDDFormEx.ExecuteNomodal(RelativePosRect: TRect; DownStateControl: TControl; Align: TDDAlign);
begin
  inherited BorderStyle := bsNone;

  DropDownMode := True;
  FModalMode := False;
  FMasterForm := Screen.ActiveCustomForm;
  FMasterFocusControl := Screen.ActiveControl;

  if Visible then
    Visible := False;

  UpdateSize;
  FDropLayout := AdjustDropDownForm(Self, RelativePosRect, Align);
  if FDropLayout = ddlAboveControl then
  begin
    FSizeGrip.Position := szgpTopRight;
    FSizeGrip2.Position := szgpTopLeft;
  end else
  begin
    FSizeGrip.Position := szgpBottomRight;
    FSizeGrip2.Position := szgpBottomLeft;
  end;

  InitElements;
  InitForm(nil);

  ModalResult := mrNone;

  FActivateShowing := True;
  try
    Visible := True;
  finally
    FActivateShowing := False;
  end;

end;

{$IFDEF VVX14}
procedure TDDFormEx.GetBorderStyles(var Style, ExStyle, ClassStyle: Cardinal);
begin
  inherited GetBorderStyles(Style, ExStyle, ClassStyle);
end;
{$ENDIF}


procedure SetWindowDropShadowStyle(Control: TWinControl; var Params: TCreateParams; SetState: Boolean);
begin
  if CheckWin32Version(5, 1) and SetState then
    Params.WindowClass.Style := Params.WindowClass.Style or CS_DROPSHADOW
  else
    Params.WindowClass.Style := Params.WindowClass.Style and not CS_DROPSHADOW;
end;

procedure TDDFormEx.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);

  if DropDownMode then
    SetWindowDropShadowStyle(Self, Params, True);
end;

procedure TDDFormEx.CreateWnd;
begin
  inherited CreateWnd;
  if not (csDesigning in ComponentState) then
  begin
    FSizeGrip.HandleNeeded;
    FSizeGrip.UpdatePosition;
    FSizeGrip.Visible := ddfeRightGrip in FormElements;
    FSizeGrip.BringToFront;
    FSizeGrip2.HandleNeeded;
    FSizeGrip2.UpdatePosition;
    FSizeGrip2.Visible := ddfeLeftGrip in FormElements;
    FSizeGrip2.BringToFront;
  end;
end;

procedure TDDFormEx.CreateHandle;
begin
  inherited CreateHandle;
end;

function TDDFormEx.DoHandleStyleMessage(var Message: TMessage): Boolean;
begin
  if Message.Msg = WM_NCPAINT
    then Result := False
{$IFDEF VVX16}
    else Result := inherited DoHandleStyleMessage(Message);
{$ELSE}
    else Result := True;
{$ENDIF}
end;

procedure TDDFormEx.DoHide;
begin
  inherited DoHide;
end;

procedure TDDFormEx.AdjustClientRect(var aRect: TRect);
begin
  inherited AdjustClientRect(aRect);
  InflateRect(aRect, -BorderWidth, -BorderWidth);
  aRect.Top := aRect.Top + BorderWidth;
end;

procedure TDDFormEx.Paint;
begin
  inherited Paint;
  DrawBorder(ClientRect);
end;

procedure TDDFormEx.DrawBorder(BorderRect: TRect);
var
  DC: HDC;
  R, RTop: TRect;
  Details: TThemedElementDetails;
  ABrush: TBrush;
begin
  DC := Canvas.Handle;
  try
    R := ClientRect;

    ExcludeClipRect(DC,
      R.Left+FBorderWidth, R.Top+FBorderWidth, R.Right-FBorderWidth, R.Bottom-FBorderWidth);

    if CustomStyleActive or not ThemesEnabled then
    begin
      ABrush := TBrush.Create;
      ABrush.Color := StyleServices.GetSystemColor(cl3DDkShadow);
      {$WARNINGS OFF}
      FrameRect(DC, R, ABrush.Handle);
      {$WARNINGS ON}
      ABrush.Color := StyleServices.GetSystemColor(cl3DLight);
      InflateRect(R, -1, -1);
      {$WARNINGS OFF}
      Windows.FrameRect(DC, R, ABrush.Handle);
      {$WARNINGS ON}
      InflateRect(R, -1, -1);
      {$WARNINGS OFF}
      Windows.FrameRect(DC, R, ABrush.Handle);
      {$WARNINGS ON}
      ABrush.Free;
    end else
    begin
      RTop := Rect(R.Left, R.Top, R.Right, R.Top + FBorderWidth);
      Details := ThemeServices.GetElementDetails(twSmallCaptionActive);
      ThemeServices.DrawElement(DC, Details, RTop);

      R.Top := R.Top + FBorderWidth;
      Details := ThemeServices.GetElementDetails(twSmallFrameBottomActive);
      ThemeServices.DrawElement(DC, Details, R);
    end;
  finally
  end;
end;


procedure TDDFormEx.WMSize(var Message: TWMSize);
begin
  inherited;
  if DropDownMode then
    Repaint;
end;

procedure TDDFormEx.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  inherited;
  if (FSizeGrip <> nil) and FSizeGrip.Visible then
  begin
    FSizeGrip.UpdatePosition;
    FSizeGrip.BringToFront;
  end;
  if (FSizeGrip2 <> nil) and FSizeGrip2.Visible then
  begin
    FSizeGrip2.UpdatePosition;
    FSizeGrip2.BringToFront;
  end;
end;

procedure TDDFormEx.WMActivate(var msg: TWMActivate);
begin
  inherited;
  if DropDownMode and not (csDesigning in ComponentState) then
  begin
    if not FModalMode and
           (msg.Active = WA_INACTIVE) and
       not FKeepFormVisible and
       not FActivateClosing and
       not FActivateShowing
    then
    begin
      FActivateClosing := True;
      try
        Close;
      finally
        FActivateClosing := False;
      end;
    end;
  end;
end;

procedure TDDFormEx.Close;
begin
  if FClosing then Exit;
  FClosing := True;
  try
    inherited Close;
  finally
    if (FMasterFocusControl <> nil) and
       not FActivateClosing and
       FMasterFocusControl.CanFocus
    then
      FMasterFocusControl.SetFocus;

    FClosing := False;
  end;
end;

procedure TDDFormEx.DoClose(var Action: TCloseAction);
begin
  inherited DoClose(Action);
end;

procedure TDDFormEx.InitForm(Host: TComponent);
begin
  if Assigned(OnInitForm) then
    OnInitForm(Self);
end;

function TDDFormEx.GetBorderStyle: TFormBorderStyle;
begin
  Result := inherited BorderStyle;
end;

function TDDFormEx.GetControlClientRect: TRect;
begin
  Result := ClientRect;
  AdjustClientRect(Result);
end;

class function TDDFormEx.GetGlobalRef: TDDFormEx;
begin
  Result := nil;
end;

procedure TDDFormEx.Loaded;
begin
  inherited Loaded;
  if not (csDesigning in ComponentState) and (FSizeGrip <> nil) then
  begin
    FSizeGrip.UpdatePosition;
    FSizeGrip.Visible := ddfeRightGrip in FormElements;
    FSizeGrip.BringToFront;
  end;

  if not (csDesigning in ComponentState) and (FSizeGrip2 <> nil) then
  begin
    FSizeGrip2.UpdatePosition;
    FSizeGrip2.Visible := ddfeLeftGrip in FormElements;
    FSizeGrip2.BringToFront;
  end;
end;

procedure TDDFormEx.InitElements;
begin

  if ddfeSizingBar in FormElements then
  begin
    FSizingBar.Visible := False;
    FSizingBar.BringToFront;
    if FDropLayout = ddlUnderControl then
    begin
      FSizingBar.Top := Height + 1;
      FSizingBar.Align := alBottom;
      FSizingBar.BevelEdges := [beTop];
    end else
    begin
      FSizingBar.Top := -1;
      FSizingBar.Align := alTop;
      FSizingBar.BevelEdges := [beBottom];
    end;
    FSizingBar.Height := GetSystemMetrics(SM_CYVSCROLL) + 3;
    FSizingBar.Visible := True;
  end else
    FSizingBar.Visible := False;

  if ddfeCloseButton in FormElements then
  begin
    FCloseButton.BringToFront;
    FCloseButton.Top :=  BorderWidth;
    FCloseButton.Left := ClientWidth - FCloseButton.Width - 3;
    FCloseButton.Visible := True;
    if FDropLayout = ddlUnderControl then
    begin
      if ddfeSizingBar in FormElements then
      begin
        if ddfeLeftGrip in FormElements
          then FCloseButton.Left := 22 // 18
          else FCloseButton.Left := 2;
        FCloseButton.Top := ClientHeight - FCloseButton.Height - BorderWidth -2 {-0};
        FCloseButton.Anchors := [akBottom, akLeft];
      end else
      begin
        FCloseButton.Left := ClientWidth - FCloseButton.Width - 3;
        FCloseButton.Anchors := [akTop, akRight];
      end
    end else
    begin
      FCloseButton.Left := ClientWidth - FCloseButton.Width - 22;// 18;
      FCloseButton.Top :=  BorderWidth;
      FCloseButton.Anchors := [akTop, akRight];
    end;
  end else
    FCloseButton.Visible := False;

  FSizeGrip.Visible := ddfeRightGrip in FormElements;
  FSizeGrip2.Visible := ddfeLeftGrip in FormElements;
end;


{ TDDFormResizeBar }

constructor TDDFormResizeBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csCaptureMouse];
  BevelOuter := bvNone;
  BevelEdges := [beTop];
  BevelKind := bkTile;
end;

destructor TDDFormResizeBar.Destroy;
begin
  inherited Destroy;
end;

procedure TDDFormResizeBar.MouseDown(Button: TMouseButton;  Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  FMouseDownPos := Point(-1,-1);
  if Align = alBottom then
  begin
    if Y > Height - FSizingArea then
      FMouseDownPos := Point(X, Y);
  end else
  begin
    if Y < FSizingArea then
      FMouseDownPos := Point(X, Y);
  end;
end;

procedure TDDFormResizeBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  Delta: Integer;
begin
  inherited MouseMove(Shift, X, Y);
  if (ssLeft in Shift) and MouseCapture and (FMouseDownPos.X <> -1) and (FMouseDownPos.Y <> -1) then
    if Align = alBottom then
      HostControl.Height := HostControl.Height + (Y - FMouseDownPos.Y)
    else
    begin
      Delta := FMouseDownPos.Y - Y;
      HostControl.SetBounds(HostControl.Left, HostControl.Top - Delta, HostControl.Width, HostControl.Height + Delta);
    end;
end;

procedure TDDFormResizeBar.Resize;
begin
  inherited Resize;
  if Height * 2 < 20
    then FSizingArea := Height div 2
    else FSizingArea := 10;
end;

procedure TDDFormResizeBar.WMSetCursor(var Msg: TWMSetCursor);
var
  P: TPoint;
begin
  P := Point(LoWord(GetMessagePos), HiWord(GetMessagePos));
  P := ScreenToClient(P);

  if Msg.HitTest = HTCLIENT then
    if Align = alBottom then
    begin
      if P.Y > Height - FSizingArea then
      begin
        Windows.SetCursor(Screen.Cursors[crSizeNS]);
        Msg.Result := 1;
      end else
        inherited;
    end else
    begin
      if P.Y < FSizingArea then
      begin
        Windows.SetCursor(Screen.Cursors[crSizeNS]);
        Msg.Result := 1;
      end else
        inherited;
    end
  else
    inherited;
end;

function TDDFormEx.GetReadOnly: Boolean;
begin
  Result := FReadOnly;
end;

procedure TDDFormEx.SetDropDownMode(const Value: Boolean);
begin
  if FDropDownMode <> Value then
  begin
    FDropDownMode := Value;
    RecreateWnd;
  end;
end;

procedure TDDFormEx.SetReadOnly(const Value: Boolean);
begin
  FReadOnly := Value;
end;

procedure TDDFormEx.Show;
begin
  DropDownMode := False;
  inherited Show;
end;

function TDDFormEx.ShowModal: Integer;
begin
  DropDownMode := False;
  inherited BorderStyle := bsDialog;
  Position := poScreenCenter;
  BorderIcons := [biSystemMenu, biMinimize, biMaximize];
  InitForm(nil);
  Result := inherited ShowModal;
end;

procedure TDDFormEx.UpdateSize;
begin

end;

procedure TDDFormEx.SetKeepFormVisible(const Value: Boolean);
begin
  FKeepFormVisible := Value;
end;

{ TDDFormResizeBarSizeGrip }

constructor TDDFormResizeBarSizeGrip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csReplicatable, csParentBackground, csCaptureMouse];
  Width := GetSystemMetrics(SM_CXVSCROLL);
  Height := GetSystemMetrics(SM_CYVSCROLL);
  Color := clBtnFace;
  Cursor := crSizeNWSE;
  FTriangleWindow := True;
  FPosition := szgpBottomRight;
end;

procedure TDDFormResizeBarSizeGrip.CreateHandle;
begin
  if HostControl <> nil then
    ParentWindow := HostControl.Handle;
  inherited CreateHandle;
end;

procedure TDDFormResizeBarSizeGrip.CreateWnd;
begin
  inherited CreateWnd;
  UpdateWindowRegion;
end;

procedure TDDFormResizeBarSizeGrip.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  FInitScreenMousePos := ClientToScreen(Point(X, Y));
  FParentRect.Right := HostControl.Width;
  FParentRect.Bottom := HostControl.Height;
  FParentRect.Left := HostControl.ClientWidth;
  FParentRect.Top := HostControl.ClientHeight;
end;

procedure TDDFormResizeBarSizeGrip.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  NewMousePos, ParentWidthHeight: TPoint;
  OldPos, NewClientAmount, OutDelta: Integer;
  WorkArea: TRect;
  MonInfo: TMonitorInfo;
  MasterAbsRect: TRect;
begin
  inherited MouseMove(Shift, X, Y);

  if (ssLeft in Shift) and MouseCapture and not FInternalMove then
  begin
    NewMousePos := ClientToScreen(Point(X, Y));
    ParentWidthHeight.x := HostControl.ClientWidth;
    ParentWidthHeight.y := HostControl.ClientHeight;

    if (FOldMouseMovePos.x = NewMousePos.x) and
      (FOldMouseMovePos.y = NewMousePos.y) then
      Exit;

    MasterAbsRect.TopLeft := HostControl.ClientToScreen(Point(0, 0));
    MasterAbsRect.Bottom := MasterAbsRect.Top + HostControl.Height;
    MasterAbsRect.Right := MasterAbsRect.Left + HostControl.Width;
    MonInfo.cbSize := SizeOf(MonInfo);
{$IFDEF CIL}
    GetMonitorInfo(MonitorFromRect(MasterAbsRect, MONITOR_DEFAULTTONEAREST), MonInfo);
{$ELSE}
    GetMonitorInfo(MonitorFromRect(@MasterAbsRect, MONITOR_DEFAULTTONEAREST), @MonInfo);
{$ENDIF}
    WorkArea := MonInfo.rcWork;

    if Position in [szgpBottomRight, szgpTopRight] then
    begin
      NewClientAmount := FParentRect.Left + NewMousePos.x - FInitScreenMousePos.x;
      OutDelta := HostControl.Width + NewClientAmount - HostControl.ClientWidth;
      OutDelta := HostControl.ClientToScreen(Point(OutDelta, 0)).x - WorkArea.Right;
      if OutDelta <= 0
        then HostControl.ClientWidth := NewClientAmount
        else HostControl.ClientWidth := NewClientAmount - OutDelta
    end else
    begin
      OldPos := HostControl.Width;

      NewClientAmount := FParentRect.Right + FInitScreenMousePos.x - NewMousePos.x;
      OutDelta := NewClientAmount - HostControl.Width;
      OutDelta := HostControl.ClientToScreen(Point(0, 0)).x - WorkArea.Left - OutDelta;
      if OutDelta >= 0
        then HostControl.Width := NewClientAmount
        else HostControl.Width := NewClientAmount + OutDelta;
      HostControl.Left := HostControl.Left + OldPos - HostControl.Width;
    end;

    if Position in [szgpBottomRight, szgpBottomLeft] then
    begin
      NewClientAmount := FParentRect.Top + NewMousePos.y - FInitScreenMousePos.y;
      OutDelta := HostControl.Height + NewClientAmount - HostControl.ClientHeight;
      OutDelta := HostControl.ClientToScreen(Point(0, OutDelta)).y - WorkArea.Bottom;
      if OutDelta <= 0
        then HostControl.ClientHeight := NewClientAmount
        else HostControl.ClientHeight := NewClientAmount - OutDelta;
    end else
    begin
      OldPos := HostControl.Height;
      NewClientAmount := FParentRect.Bottom + FInitScreenMousePos.y - NewMousePos.y;
      OutDelta := NewClientAmount - HostControl.Height;
      OutDelta := HostControl.ClientToScreen(Point(0, 0)).y - WorkArea.Top - OutDelta;
      if OutDelta >= 0
        then HostControl.Height := NewClientAmount
        else HostControl.Height := NewClientAmount + OutDelta;
      HostControl.Top := HostControl.Top + OldPos - HostControl.Height;
    end;

    FOldMouseMovePos := NewMousePos;
    if (ParentWidthHeight.x <> HostControl.ClientWidth) or
      (ParentWidthHeight.y <> HostControl.ClientHeight) then
      ParentResized;
    UpdatePosition;
  end;
end;

procedure TDDFormResizeBarSizeGrip.Paint;
{$IFDEF VVX16}
const  PositionElementDetailsArr: array [TSZGripPosition] of TThemedScrollBar =
  (tsSizeBoxTopLeftAlign, tsSizeBoxTopRightAlign, tsSizeBoxRightAlign, tsSizeBoxLeftAlign);
{$ENDIF}
var
  i, xi, yi: Integer;
  XArray: array of Integer;
  YArray: array of Integer;
  xIdx, yIdx: Integer;
  BtnHighlightColor, BtnShadowColor, BtnFaceColor: TColor;
{$IFDEF VVX16}
  LColor: TColor;
  LStyle: TCustomStyleServices;
  LDetails: TThemedElementDetails;
{$ENDIF}
{$IFDEF VVX16}
  ElementDetails: TThemedElementDetails;
{$ENDIF}
begin

{$IFDEF VVX16}
  if ThemeServices.ThemesEnabled and not CustomStyleActive then
  begin
    ElementDetails := ThemeServices.GetElementDetails(PositionElementDetailsArr[Position]);
    ThemeServices.DrawElement(Canvas.Handle, ElementDetails, Rect(0,0,Width,Height));
    Exit;
  end;
{$ENDIF}

  i := 1;
  SetLength(XArray, 2);
  SetLength(YArray, 2);
  if Position = szgpBottomRight then
  begin
    xi := 1; yi := 1;
    xIdx := 0; yIdx := 1;
    XArray[0] := 0; YArray[0] := Width;
    XArray[1] := Width; YArray[1] := 0;
  end else if Position = szgpBottomLeft then
  begin
    xi := -1; yi := 1;
    xIdx := 1; yIdx := 0;
    XArray[0] := 0; YArray[0] := 1;
    XArray[1] := Width - 1; YArray[1] := Width;
  end else if Position = szgpTopLeft then
  begin
    xi := -1; yi := -1;
    xIdx := 0; yIdx := 1;
    XArray[0] := Width - 1; YArray[0] := -1;
    XArray[1] := -1; YArray[1] := Width - 1;
  end else
  begin
    xi := 1; yi := -1;
    xIdx := 1; yIdx := 0;
    XArray[0] := Width; YArray[0] := Width - 1;
    XArray[1] := 0; YArray[1] := -1;
  end;

  BtnHighlightColor := clBtnHighlight;
  BtnShadowColor := clBtnShadow;
  BtnFaceColor := clBtnFace;
{$IFDEF VVX16}
  if TStyleManager.IsCustomStyleActive then
  begin
    LStyle := StyleServices;
    if LStyle.Enabled then
    begin
      LDetails := LStyle.GetElementDetails(tpPanelBackground);
      if LStyle.GetElementColor(LDetails, ecFillColor, LColor) and (LColor <> clNone) then
        BtnFaceColor := LColor;
      LDetails := LStyle.GetElementDetails(tpPanelBevel);
      if LStyle.GetElementColor(LDetails, ecEdgeHighLightColor, LColor) and (LColor <> clNone) then
        BtnHighlightColor := LColor;
      if LStyle.GetElementColor(LDetails, ecEdgeShadowColor, LColor) and (LColor <> clNone) then
        BtnShadowColor := LColor;
    end;
  end;
{$ENDIF}

  while i < Width do
  begin
    Canvas.Pen.Color := BtnHighlightColor;
    Canvas.PolyLine([Point(XArray[0], YArray[0]), Point(XArray[1], YArray[1])]);
    Inc(i); Inc(XArray[xIdx], xi); Inc(YArray[YIdx], yi);

    Canvas.Pen.Color := BtnShadowColor;
    Canvas.PolyLine([Point(XArray[0], YArray[0]), Point(XArray[1], YArray[1])]);
    Inc(i); Inc(XArray[xIdx], xi); Inc(YArray[yIdx], yi);
    Canvas.PolyLine([Point(XArray[0], YArray[0]), Point(XArray[1], YArray[1])]);
    Inc(i); Inc(XArray[xIdx], xi); Inc(YArray[yIdx], yi);

    Canvas.Pen.Color := BtnFaceColor;
    Canvas.PolyLine([Point(XArray[0], YArray[0]), Point(XArray[1], YArray[1])]);
    Inc(i); Inc(XArray[xIdx], xi); Inc(YArray[yIdx], yi);
  end;
end;

procedure TDDFormResizeBarSizeGrip.ParentResized;
begin
  if Assigned(FParentResized) then FParentResized(Self);
end;

procedure TDDFormResizeBarSizeGrip.SetPosition(const Value: TSZGripPosition);
begin
  if FPosition = Value then Exit;
  FPosition := Value;
  if HandleAllocated then
  begin
   // RecreateWndHandle;
   if WindowHandle <> 0 then Perform(CM_RECREATEWND, 0, 0);
    HandleNeeded;
  end;
end;

procedure TDDFormResizeBarSizeGrip.SetTriangleWindow(const Value: Boolean);
begin
  if FTriangleWindow = Value then Exit;
  FTriangleWindow := Value;
  UpdateWindowRegion;
end;

procedure TDDFormResizeBarSizeGrip.UpdatePosition;
var
  HostCliRect: TRect;
begin
  if not HandleAllocated then Exit;
  FInternalMove := True;
  HostCliRect := GetAdjustedClientRect(HostControl);
  case Position of
    szgpBottomRight: SetBounds(HostCliRect.Right - Width, HostCliRect.Bottom - Height, Width, Height);
    szgpBottomLeft: SetBounds(HostCliRect.Left, HostCliRect.Bottom - Height, Width, Height);
    szgpTopLeft: SetBounds(HostCliRect.Left, HostCliRect.Top, Width, Height);
    szgpTopRight: SetBounds(HostCliRect.Right - Width, HostCliRect.Top, Width, Height);
  end;
  FInternalMove := False;
end;

procedure TDDFormResizeBarSizeGrip.ChangePosition(NewPosition: TSZGripChangePosition);
begin
  if NewPosition = szgcpToLeft then
  begin
    if Position = szgpTopRight then Position := szgpTopLeft
    else if Position = szgpBottomRight then Position := szgpBottomLeft;
  end else if NewPosition = szgcpToRight then
  begin
    if Position = szgpTopLeft then Position := szgpTopRight
    else if Position = szgpBottomLeft then Position := szgpBottomRight
  end else if NewPosition = szgcpToTop then
  begin
    if Position = szgpBottomRight then Position := szgpTopRight
    else if Position = szgpBottomLeft then Position := szgpTopLeft
  end else if NewPosition = szgcpToBottom then
  begin
    if Position = szgpTopRight then Position := szgpBottomRight
    else if Position = szgpTopLeft then Position := szgpBottomLeft
  end
end;

function TDDFormResizeBarSizeGrip.GetVisible: Boolean;
begin
  Result := IsWindowVisible(Handle);
end;

procedure TDDFormResizeBarSizeGrip.SetVisible(const Value: Boolean);
begin
  if HandleAllocated then
  begin
    if Value then
      ShowWindow(Handle, SW_SHOW)
    else
      ShowWindow(Handle, SW_HIDE);
  end else
    inherited Visible := Value;
end;

procedure TDDFormResizeBarSizeGrip.UpdateWindowRegion;
const
  PositionArr: array[TSZGripPosition] of TCursor = (crSizeNWSE, crSizeNESW, crSizeNWSE, crSizeNESW);
var
  Points: array[0..2] of TPoint;
  Region: HRgn;
begin
  if not HandleAllocated then Exit;
  if TriangleWindow then
  begin
    if Position = szgpBottomRight then
    begin
      Points[0] := Point(0, Height);
      Points[1] := Point(Width, Height);
      Points[2] := Point(Width, 0);
    end else if Position = szgpBottomLeft then
    begin
      Points[0] := Point(Width, Height);
      Points[1] := Point(0, Height);
      Points[2] := Point(0, 0);
    end else if Position = szgpTopLeft then
    begin
      Points[0] := Point(Width - 1, 0);
      Points[1] := Point(0, 0);
      Points[2] := Point(0, Height - 1);
    end else if Position = szgpTopRight then
    begin
      Points[0] := Point(Width, Height - 1);
      Points[1] := Point(Width, 0);
      Points[2] := Point(1, 0);
    end;
    Region := WindowsCreatePolygonRgn(Points, 3, WINDING);
    SetWindowRgn(Handle, Region, True);
    UpdatePosition;
  end else
  begin
    SetWindowRgn(Handle, 0, True);
    UpdatePosition;
  end;
  Cursor := PositionArr[Position];
end;

function TDDFormResizeBarSizeGrip.GetHostControl: TWinControl;
begin
  if FHostControl <> nil
    then Result := FHostControl
    else Result := Parent;
end;

procedure TDDFormResizeBarSizeGrip.SetHostControl(const Value: TWinControl);
begin
  FHostControl := Value;
end;


initialization
  RegisterClasses;
finalization
  UnregisterClasses;
end.

