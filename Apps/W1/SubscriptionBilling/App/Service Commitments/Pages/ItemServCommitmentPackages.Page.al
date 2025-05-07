namespace Microsoft.SubscriptionBilling;

using Microsoft.Inventory.Item;

page 8061 "Item Serv. Commitment Packages"
{
    Caption = 'Item Subscription Packages';
    PageType = List;
    SourceTable = "Item Subscription Package";
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
                    ToolTip = 'Specifies a code to identify this Subscription Package.';
                    trigger OnValidate()
                    begin
                        CurrPage.Update();
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        SubscriptionPackage: Record "Subscription Package";
                    begin
                        OnBeforeCodeLookup(SubscriptionPackage, CurrentItemNo);
                        if Page.RunModal(Page::"Service Commitment Packages", SubscriptionPackage) = Action::LookupOK then
                            Rec.Validate(Code, SubscriptionPackage.Code);
                        CurrPage.Update();
                    end;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a description of the Subscription Package.';
                }
                field(Standard; Rec.Standard)
                {
                    ToolTip = 'Specifies whether the package Subscription Lines should be automatically added to the sales process when the item is sold. If the checkbox is not set, the package Subscription Lines can be added manually in the sales process.';
                }
                field("Price Group"; Rec."Price Group")
                {
                    ToolTip = 'Specifies the customer price group that will be used for the invoicing of Subscription Lines.';
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
        CurrentItemNo := CopyStr(Rec.GetFilter("Item No."), 1, MaxStrLen(Rec."Item No."));
        CurrPage.PackageLines.Page.SetItemNo(CurrentItemNo);
        Rec.FilterGroup(0);
        if PersonalizationDataMgmt.GetDataPagePersonalization(8, CurrPage.ObjectId(false), 'SHOWALLPACKAGELINES', ShowAllPackageLinesText) then
            if Evaluate(ShowAllPackageLines, ShowAllPackageLinesText) then
                CurrPage.PackageLines.Page.SetShowAllPackageLines(ShowAllPackageLines);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    var
        Item: Record Item;
    begin
        if Item.Get(Rec."Item No.") then
            if Item."Subscription Option" = Item."Subscription Option"::"Service Commitment Item" then
                Rec.Standard := true;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Insert(true);
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

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCodeLookup(var SubscriptionPackage: Record "Subscription Package"; CurrentItemNo: Code[20])
    begin
    end;

    var
        PersonalizationDataMgmt: Codeunit "Personalization Data Mgmt.";
        CurrentItemNo: Code[20];
        ShowAllPackageLines: Boolean;
}
