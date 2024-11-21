pageextension 5240 "Company Creation Wizard Ext" extends "Company Creation Wizard"
{
    layout
    {
        addafter("Available Modules")
        {
            part("Contoso Modules Part"; "Contoso Modules Part")
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        modify(ActionFinish)
        {
            trigger OnAfterAction()
            var
                TempContosoDemoDataModule: Record "Contoso Demo Data Module" temporary;
                CompanyCreationContoso: Codeunit "Company Creation Contoso";
                NewCompanyData: Enum "Company Demo Data Type";
            begin
                NewCompanyData := GetNewCompanyData();

                if not (NewCompanyData in [Enum::"Company Demo Data Type"::"Production - Setup Data Only", Enum::"Company Demo Data Type"::"Evaluation - Contoso Sample Data"]) then
                    exit;

                CurrPage."Contoso Modules Part".Page.GetContosoRecord(TempContosoDemoDataModule);
                CompanyCreationContoso.CreateContosoDemodataInCompany(TempContosoDemoDataModule, GetNewCompanyName(), NewCompanyData);
            end;
        }
        addbefore(ActionBack)
        {
            action("Select All")
            {
                ApplicationArea = All;
                Caption = 'Select All';
                Image = AllLines;
                InFooterBar = true;
                Visible = DemoDataStepVisible;

                trigger OnAction()
                var
                    TempContosoDemoDataModule: Record "Contoso Demo Data Module" temporary;
                begin
                    CurrPage."Contoso Modules Part".Page.GetContosoRecord(TempContosoDemoDataModule);
                    TempContosoDemoDataModule.ModifyAll(Install, true);
                    CurrPage."Contoso Modules Part".Page.SetContosoRecord(TempContosoDemoDataModule);
                end;
            }
        }
        modify(ActionNext)
        {
            trigger OnAfterAction()
            var
                Step: Option Start,Creation,"Demo Data","Add Users",Finish;
            begin
                if GetStep() = Step::"Demo Data" then
                    DemoDataStepVisible := true
                else
                    DemoDataStepVisible := false;
            end;
        }
        modify(ActionBack)
        {
            trigger OnAfterAction()
            var
                Step: Option Start,Creation,"Demo Data","Add Users",Finish;
            begin
                if GetStep() = Step::"Demo Data" then
                    DemoDataStepVisible := true
                else
                    DemoDataStepVisible := false;
            end;
        }
    }

    var
        DemoDataStepVisible: Boolean;
}