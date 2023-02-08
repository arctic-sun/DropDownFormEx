object Form2: TForm2
  Left = 0
  Top = 0
  Caption = 'Form2'
  ClientHeight = 666
  ClientWidth = 948
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -18
  Font.Name = 'Segoe UI'
  Font.Style = []
  PixelsPerInch = 144
  TextHeight = 25
  object Edit1: TEdit
    Left = 72
    Top = 288
    Width = 182
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 0
    Text = 'Edit1'
  end
  object Memo1: TMemo
    Left = 72
    Top = 72
    Width = 278
    Height = 134
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Lines.Strings = (
      'Memo1')
    TabOrder = 1
  end
  object Button1: TButton
    Left = 492
    Top = 216
    Width = 113
    Height = 38
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = 'Button1'
    TabOrder = 2
  end
  object CheckBox1: TCheckBox
    Left = 72
    Top = 331
    Width = 146
    Height = 26
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = 'CheckBox1'
    TabOrder = 3
  end
  object RadioButton1: TRadioButton
    Left = 72
    Top = 367
    Width = 170
    Height = 26
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Caption = 'RadioButton1'
    TabOrder = 4
  end
  object ListBox1: TListBox
    Left = 420
    Top = 307
    Width = 303
    Height = 198
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    ItemHeight = 25
    Items.Strings = (
      '1'
      '2'
      '3'
      '4'
      '5'
      '6'
      '7')
    TabOrder = 5
  end
  object ComboBox1: TComboBox
    Left = 72
    Top = 420
    Width = 218
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    TabOrder = 6
    Text = 'ComboBox1'
  end
  object DatePicker1: TDatePicker
    Left = 72
    Top = 216
    Width = 225
    Height = 62
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Date = 44965.000000000000000000
    DateFormat = 'ddd/dd.mm.yy'
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -36
    Font.Name = 'Segoe UI'
    Font.Style = []
    TabOrder = 7
  end
  object DateTimePicker1: TDateTimePicker
    Left = 444
    Top = 144
    Width = 279
    Height = 33
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    Date = 44965.000000000000000000
    Time = 0.492286273147328800
    TabOrder = 8
  end
  object PageControl1: TPageControl
    Left = 60
    Top = 480
    Width = 290
    Height = 134
    Margins.Left = 5
    Margins.Top = 5
    Margins.Right = 5
    Margins.Bottom = 5
    ActivePage = TabSheet2
    TabOrder = 9
    object TabSheet1: TTabSheet
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Caption = 'TabSheet1'
    end
    object TabSheet2: TTabSheet
      Margins.Left = 5
      Margins.Top = 5
      Margins.Right = 5
      Margins.Bottom = 5
      Caption = 'TabSheet2'
      ImageIndex = 1
    end
  end
end
