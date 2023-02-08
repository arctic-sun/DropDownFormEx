unit Unit2;

interface

uses
  DDFormEx,
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls, Vcl.WinXPickers, Vcl.StdCtrls;

type
  TForm2 = class(TDDFormEx)
    Edit1: TEdit;
    Memo1: TMemo;
    Button1: TButton;
    CheckBox1: TCheckBox;
    RadioButton1: TRadioButton;
    ListBox1: TListBox;
    ComboBox1: TComboBox;
    DatePicker1: TDatePicker;
    DateTimePicker1: TDateTimePicker;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

end.
