namespace Microsoft.API.V1;

using System.Environment;
using System.IO;

page 20054 "APIV1 - Aut. Conf. Pack. File"
{
#pragma warning disable AA0218
    Caption = 'configurationPackageFile', Locked = true;
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Tenant Config. Package File";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
#pragma warning disable AL0273
#pragma warning disable AW0004
                field(content; Rec.Content)
#pragma warning restore
                {
                    ApplicationArea = All;
                    Caption = 'Specifies the content.', Locked = true;
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
            CodeFilter := Rec.GetFilter(Code);
            if CodeFilter = '' then
                Error(CodeNotSpecifiedForLinesErr);
            if not Rec.FindFirst() then
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
#pragma warning restore
}


