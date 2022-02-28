page 30057 "APIV2 - Aut. Conf. Pack. File"
{
    DelayedInsert = true;
    Extensible = false;
    PageType = ListPart;
    SourceTable = "Tenant Config. Package File";
    ODataKeyFields = Code;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(code; Rec.Code)
                {
                    ApplicationArea = All;
                    Caption = 'Code';
                    Editable = false;
                    ToolTip = 'Specifies a code for the configuration package.';
                }
#pragma warning disable AL0273
#pragma warning disable AW0004
                field(content; Rec.Content)
#pragma warning restore AL0273
#pragma warning restore AW0004
                {
                    ApplicationArea = All;
                    Caption = 'Content';
                    ToolTip = 'Specifies a contect package.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnFindRecord(Which: Text): Boolean
    var
        CodeFilter: Text;
    begin
        if not FilesLoaded then begin
            CodeFilter := GetFilter(Code);
            if CodeFilter = '' then
                Error(CodeNotSpecifiedForLinesErr);
            if not FindFirst() then
                exit(false);
            FilesLoaded := true;
        end;

        exit(true);
    end;

    trigger OnOpenPage()
    begin
        BindSubscription(AutomationAPIManagement);
    end;

    var
        AutomationAPIManagement: Codeunit "Automation - API Management";
        FilesLoaded: Boolean;
        CodeNotSpecifiedForLinesErr: Label 'You must specify a Configuration Package Code before uploading a Configuration Package File.', Locked = true;
}