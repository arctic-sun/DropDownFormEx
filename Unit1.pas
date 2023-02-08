unit Unit1;

interface

uses
  DDFormEx, Unit2,

  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm6 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
    function GetElements: TDDFormExElements;
    function GetAlign: TDDAlign;
  public
    { Public declarations }
  end;

var
  Form6: TForm6;

implementation

{$R *.dfm}


function TForm6.GetElements: TDDFormExElements;
begin
  if   CheckBox1.Checked then Include(Result, ddfeLeftGrip )    else Exclude(Result, ddfeLeftGrip )     ;
  if   CheckBox2.Checked then Include(Result, ddfeRightGrip )   else Exclude(Result, ddfeRightGrip )    ;
  if   CheckBox3.Checked then Include(Result, ddfeCloseButton ) else Exclude(Result, ddfeCloseButton )  ;
  if   CheckBox4.Checked then Include(Result, ddfeSizingBar )   else Exclude(Result, ddfeSizingBar )    ;
end;

function TForm6.GetAlign: TDDAlign;// = (, ddRight, );
begin
 if RadioButton1.Checked then Result := ddLeft ;
 if RadioButton2.Checked then Result := ddCenter ;
 if RadioButton3.Checked then Result := ddRight ;
end;


procedure TForm6.Button1Click(Sender: TObject);
begin
  Form2.FormElements := GetElements; // [ ddfeRightGrip, ddfeCloseButton, ddfeSizingBar];
  Form2.Execute(  TButton(Sender), nil, GetAlign {ddLeft}  );
end;

procedure TForm6.Button2Click(Sender: TObject);
begin
  Form2.FormElements := GetElements; // [ ddfeRightGrip, ddfeCloseButton, ddfeSizingBar];
  Form2.ExecuteNomodal( ClientToScreenRect(TButton(Sender)) , nil, GetAlign {ddLeft});
end;

end.
