namespace Microsoft.SubscriptionBilling;

using System.Utilities;
using System.Integration;

page 8029 "Text Viewer"
{
    Caption = 'Text Viewer';
    DataCaptionExpression = PageCaptionText;
    PageType = StandardDialog;
    ApplicationArea = All;


    layout
    {
        area(content)
        {
            group(Control1105660002)
            {
                ShowCaption = false;
                usercontrol(TextEditorAddin; WebPageViewer)
                {

                    trigger ControlAddInReady(callbackUrl: Text)
                    begin
                        CurrPage.TextEditorAddin.SetContent(StrSubstNo(TextAreaLbl, ContentText, MaxStrLen(ContentText), ReadOnly, Height, Width, AutoResize));
                    end;

                    trigger Callback(data: Text)
                    begin
                        if data <> ContentText then
                            ContentText := data;
                    end;

                    trigger Refresh(callbackUrl: Text)
                    begin
                        CurrPage.TextEditorAddin.SetContent(StrSubstNo(TextAreaLbl, ContentText, MaxStrLen(ContentText), ReadOnly, Height, Width, AutoResize));
                    end;
                }
            }
        }
    }
    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        ConfirmManagement: Codeunit "Confirm Management";
    begin
        if CloseOk or (ReadOnly <> '') then
            exit(true);

        if CloseAction = Action::Cancel then
            if OldContentText <> ContentText then
                if not ConfirmManagement.GetResponseOrDefault(TimeRecordingDescriptionNotSavedQst, false) then
                    exit(false);

        exit(true);
    end;

    trigger OnOpenPage()
    begin
        OldContentText := ContentText;
    end;

    procedure SetContent(NewContent: Text)
    begin
        ContentText := NewContent;
    end;

    procedure GetContent(): Text
    begin
        exit(ContentText);
    end;

    procedure SetPageCaption(NewPageCaption: Text)
    begin
        PageCaptionText := NewPageCaption;
    end;

    procedure SetReadOnly(NewReadOnly: Boolean)
    begin
        if NewReadOnly then
            ReadOnly := 'readonly=""'
        else
            ReadOnly := '';
    end;

    procedure SetSize(NewHeight: Decimal; NewWidth: Decimal)
    begin
        Height := NewHeight;
        Width := NewWidth;
    end;

    procedure SetAutoResize(NewAutoResize: Boolean)
    begin
        AutoResize := NewAutoResize;
    end;

    var
        TextAreaLbl: Label '<textarea Id="TextArea" %3 maxlength="%2" style="width:%4%;height:%5%;autoresize: %6; font-family:"Segoe UI", "Segoe WP", Segoe, device-segoe, Tahoma, Helvetica, Arial, sans-serif !important; font-size: 10.5pt !important;" OnChange="window.parent.WebPageViewerHelper.TriggerCallback(document.getElementById(''TextArea'').value)">%1</textarea>', Locked = true;
        TimeRecordingDescriptionNotSavedQst: Label 'Do you want to discard the changes close the editor without saving?';
        ContentText: Text;
        OldContentText: Text;
        PageCaptionText: Text;
        ReadOnly: Text;
        Height: Decimal;
        Width: Decimal;
        AutoResize: Boolean;
        CloseOk: Boolean;
}
