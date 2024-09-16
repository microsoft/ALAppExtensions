namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

page 8061 "Item Serv. Commitment Packages"
{
    Caption = 'Item Service Commitment Packages';
    PageType = List;
    SourceTable = "Item Serv. Commitment Package";
    UsageCategory = None;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {
                    ShowMandatory = true;
                    ToolTip = 'Specifies a code to identify this service commitment package.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the service commitment package.';
                }
                field(Standard; Rec.Standard)
                {
                    ToolTip = 'Specifies whether the package service commitments should be automatically added to the sales process when the item is sold. If the checkbox is not set, the package service commitments can be added manually in the sales process.';
                }
                field("Price Group"; Rec."Price Group")
                {
                    ToolTip = 'Specifies the customer price group that will be used for the invoicing of services.';
                }
            }
            part(PackageLines; "Service Comm. Package Lines")
            {
                Editable = false;
                UpdatePropagation = Both;
            }
        }
    }
    actions
    {
        area(processing)
        {
            action(ShowAllPackageLinesAction)
            {
                Caption = 'Show all or single package(s)';
                Image = ShowList;
                ToolTip = 'Toggle visibility of package lines to a single package or to all packages.';

                trigger OnAction()
                begin
                    ShowAllPackageLines := not ShowAllPackageLines;
                    PersonalizationDataMgmt.SetDataPagePersonalization(8, CurrPage.ObjectId(false), 'SHOWALLPACKAGELINES', Format(ShowAllPackageLines));
                    CurrPage.PackageLines.Page.SetShowAllPackageLines(ShowAllPackageLines);
                    CurrPage.PackageLines.Page.SetPackageCode(Rec.Code);
                    CurrPage.Update();
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(ShowAllPackageLinesAction_Promoted; ShowAllPackageLinesAction)
                {
                }
            }
        }
    }
    trigger OnOpenPage()
    var
        ShowAllPackageLinesText: Text;
    begin
        Rec.FilterGroup(2);
        CurrPage.PackageLines.Page.SetItemNo(CopyStr(Rec.GetFilter("Item No."), 1, MaxStrLen(Rec."Item No.")));
        Rec.FilterGroup(0);
        if PersonalizationDataMgmt.GetDataPagePersonalization(8, CurrPage.ObjectId(false), 'SHOWALLPACKAGELINES', ShowAllPackageLinesText) then
            if Evaluate(ShowAllPackageLines, ShowAllPackageLinesText) then
                CurrPage.PackageLines.Page.SetShowAllPackageLines(ShowAllPackageLines);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Item.Get(Rec."Item No.") then
            if Item."Service Commitment Option" = Item."Service Commitment Option"::"Service Commitment Item" then
                Rec.Standard := true;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Insert(false);
        CurrPage.PackageLines.Page.SetPackageCode(Rec.Code);
        exit(false);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.Delete(false);
        CurrPage.PackageLines.Page.SetPackageCode('');
        exit(false);
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrPage.PackageLines.Page.SetPackageCode(Rec.Code);
    end;

    var
        Item: Record Item;
        PersonalizationDataMgmt: Codeunit "Personalization Data Mgmt.";
        ShowAllPackageLines: Boolean;
}
