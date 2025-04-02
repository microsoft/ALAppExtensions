namespace Microsoft.Integration.Shopify;

using System.Environment;
using Microsoft.Inventory.Item;
using Microsoft.Sales.Customer;
using Microsoft.Finance.GeneralLedger.Account;
using System.Environment.Configuration;
using Microsoft.Foundation.Company;
using System.Telemetry;
using System.Utilities;

page 30136 "Shpfy Connector Guide"
{
    Caption = 'Shopify Connector Setup';
    PageType = NavigatePage;
    ApplicationArea = All;
    UsageCategory = Administration;
    Permissions = tabledata "Shpfy Initial Import Line" = rimd;

    layout
    {
        area(Content)
        {
            group(StandardBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and not FinishActionEnabled;
                field(MediaResourcesStd; MediaResourcesStandard."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(FinishedBanner)
            {
                Caption = '';
                Editable = false;
                Visible = TopBannerVisible and FinishActionEnabled;
                field(MediaResourcesDone; MediaResourcesDone."Media Reference")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                }
            }
            group(Step1)
            {
                Visible = Step1Visible;
                group("Welcome to Shopify Connector Setup")
                {
                    Caption = 'Welcome to Shopify Connector Setup';
                    InstructionalText = 'This guide will connect Business Central to your shop on Shopify. We''ll create a new shop in Business Central, and help you import data you may already have on Shopify.';
                }
                group(Note)
                {
                    Caption = 'Note';
                    InstructionalText = 'While you''re using a demo company, we want to keep things safe for your Shopify store. You can use this guide to import up to 25 products from Shopify, but you can''t export Business Central data to your store.';
                    Visible = IsDemoCompany;
                }
            }
            group(StepConsent)
            {
                InstructionalText = 'Review the terms and conditions.';
                Visible = ConsentStepVisible;
                field(ConsentLbl; ConsentLbl)
                {
                    ApplicationArea = All;
                    ShowCaption = false;
                    Editable = false;
                    Caption = ' ';
                    MultiLine = true;
                    ToolTip = 'Accept the terms and conditions.';
                }
                field(Consent; ConsentVar)
                {
                    ApplicationArea = All;
                    Caption = 'I accept';
                    ToolTip = 'Accept the terms and conditions.';

                    trigger OnValidate()
                    begin
                        NextActionEnabled := false;
                        if ConsentVar then
                            NextActionEnabled := true;
                    end;
                }
                field(LearnMore; LearnMoreTok)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ShowCaption = false;
                    Caption = ' ';
                    ToolTip = 'View information about the privacy.';

                    trigger OnDrillDown()
                    begin
                        Hyperlink(PrivacyLinkTxt);
                    end;
                }
            }
            group(Step2)
            {
                ShowCaption = false;
                Visible = Step2Visible;

                group(Control0)
                {
                    Caption = 'We found your shop on Shopify';
                    InstructionalText = 'We found this URL for your shop on Shopify. You can use the URL for another shop if you want.';
                    Visible = IsShopifyContext;
                }

                group(Control1)
                {
                    Caption = 'Enter the URL for your shop on Shopify';
                    InstructionalText = 'The URL must refer to the internal shop location at myshopify.com. It must not be the public URL that customers use, such as myshop.com.';
                    Visible = not IsShopifyContext;
                }

                field(ShopUrl; ShopUrl)
                {
                    Caption = 'Shopify Admin URL';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the URL of the Shopify Admin you are connecting to. Use the format: "https://{store ID}.myshopify.com". You can build the URL by combining the store ID from the admin URL, e.g., "admin.shopify.com/store/{store ID}" and ".myshopify.com". Simply copy the URL from the Shopify Admin, and the connector will convert it to the required format. Ensure you copy the URL from the Shopify Admin, not the online store, as the online store may display a redirect URL.';

                    trigger OnValidate()
                    var
                        AuthenticationMgt: Codeunit "Shpfy Authentication Mgt.";
                    begin
                        if ShopUrl = '' then
                            NextActionEnabled := false
                        else begin
                            AuthenticationMgt.CorrectShopUrl(ShopUrl);
                            if not AuthenticationMgt.IsValidShopUrl(ShopUrl) then
                                Error(InvalidShopUrlErr);
                            NextActionEnabled := true;
                        end;
                        CurrPage.Update();
                    end;
                }

                group(Control2)
                {
                    InstructionalText = 'When you choose Next you''ll be asked to sign in to your Shopify account and request access to your Shopify shop.';
                    ShowCaption = false;

                    group(Control5)
                    {
                        Visible = AccessRequested and (not CorrectConnection);
                        ShowCaption = false;

                        field(ConnectionUnsuccessful; ConnectionUnsuccessfulLbl)
                        {
                            ApplicationArea = All;
                            Tooltip = 'Indicates that the administrator user could not sign-in to Shopify.';
                            Caption = 'Could not connect to Shopify';
                            Editable = false;
                            ShowCaption = false;
                            Style = Unfavorable;
                        }
                    }
                }
            }
            group(Step3)
            {
                Visible = Step3Visible;
                ShowCaption = false;

                group(Control6)
                {
                    Caption = 'Get started with Business Central by importing data from Shopify';
                    InstructionalText = 'This guide can help you quickly get started with Business Central. You can import the products and customers from Shopify that you want to manage in Business Central. You can use this guide only one time';
                }

                field("Import Products From Shopify"; ImportProducts)
                {
                    Caption = 'Import Products From Shopify';
                    ApplicationArea = All;
                    ToolTip = 'Import products from Shopify.';
                }
                field("Import Customers From Shopify"; ImportCustomers)
                {
                    Caption = 'Import Customers From Shopify';
                    ApplicationArea = All;
                    ToolTip = 'Import customers from Shopify.';
                }
            }
            group(Step4)
            {
                Visible = Step4Visible;
                ShowCaption = false;

                group(Control7)
                {
                    Caption = 'Sorry, we can''t import your data.';
                    InstructionalText = 'You already have items in Business Central. Review the settings for your shop to ensure that your Shopify products map correctly to Business Central items, and then manually import your products.';
                }
            }
            group(Step5)
            {
                Visible = Step5Visible;
                ShowCaption = false;

                group(Control8)
                {
                    Caption = 'Specify how to create items';
                    InstructionalText = 'Products in Shopify are called items in Business Central. This guide can help you import your Shopify products to Business Central. You can use this guide only one time.';
                }
                group(Control9)
                {
                    ShowCaption = false;
                    InstructionalText = 'Here are the important settings for getting started.';

                    field("Sync Item Images"; SyncItemImages)
                    {
                        Caption = 'Sync Item Images';
                        ApplicationArea = All;
                        ToolTip = 'Import product images from Shopify.';
                    }
                    field("Item Template Code"; ItemTemplateCode)
                    {
                        Caption = 'Item Template Code';
                        ApplicationArea = All;
                        Lookup = true;
                        LookupPageId = "Select Item Templ. List";
                        ToolTip = 'Specifies the item template to use when creating items in Business Central. These are products in Shopify that don''t exist as items in Business Central.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if LookUpItemTemplateCode(ItemTemplateCode) then
                                NextActionEnabled := true;
                        end;

                        trigger OnValidate()
                        var
                            ItemTempl: Record "Item Templ.";
                        begin
                            if ItemTemplateCode = '' then begin
                                NextActionEnabled := false;
                                exit;
                            end;
                            ItemTempl.Get(ItemTemplateCode);
                            NextActionEnabled := true;
                        end;
                    }
                }
            }
            group(Step6)
            {
                Visible = Step6Visible;
                ShowCaption = false;

                group(Control10)
                {
                    Caption = 'Specify how to create customers';
                    InstructionalText = 'You''ve chosen to import customers. Here are some important settings that define how to create them in Business Central.';
                }
                group(Control11)
                {
                    ShowCaption = false;
                    InstructionalText = 'You should only import customers for whom you want to track order activity in Business Central. For example, the customers that you often do business with.';

                    field("Customer Template Code"; CustomerTemplateCode)
                    {
                        Caption = 'Customer Template Code';
                        ApplicationArea = All;
                        Lookup = true;
                        LookupPageId = "Select Customer Templ. List";
                        ToolTip = 'Specifies the customer template to use to create unknown customers. These are customers in Shopify that don''t already exist in Business Central.';

                        trigger OnLookup(var Text: Text): Boolean
                        begin
                            if LookupCustomerTemplateCode(CustomerTemplateCode) then
                                NextActionEnabled := true;
                        end;

                        trigger OnValidate()
                        var
                            CustomerTempl: Record "Customer Templ.";
                        begin
                            if CustomerTemplateCode = '' then begin
                                NextActionEnabled := false;
                                exit;
                            end;
                            CustomerTempl.Get(CustomerTemplateCode);
                            NextActionEnabled := true;
                        end;
                    }
                }
            }
            group(Step7)
            {
                Visible = Step7Visible;
                ShowCaption = false;

                group(Control12)
                {
                    Caption = 'Specify how orders should be created';
                    InstructionalText = 'Orders that you synch from Shopify can automatically become sales orders in Business Central (recommended). The item quantities on these orders are then part of inventory planning and availability in Business Central. You can also import orders to the Shopify Orders page and then turn them into sales orders manually. ';
                }
                group(Control13)
                {
                    ShowCaption = false;
                    InstructionalText = 'Additionally, choose the G/L account to use for shipping costs from Shopify.';

                    field("Auto Create Orders"; AutoCreateOrders)
                    {
                        Caption = 'Auto Create Orders';
                        ApplicationArea = All;
                        ToolTip = 'Specifies whether to automatically create orders.';
                    }
                    field("Shipping Charges Account"; ShippingChargesAccountNo)
                    {
                        Caption = 'Shipping Charges Account';
                        ApplicationArea = All;
                        Lookup = true;
                        LookupPageId = "G/L Account List";
                        ToolTip = 'Specifies the G/L account to use for shipping costs from Shopify.';

                        trigger OnLookup(var Text: Text): Boolean
                        var
                            GLAccount: Record "G/L Account";
                        begin
                            if Page.RunModal(Page::"G/L Account List", GLAccount) = Action::LookupOK then begin
                                ShippingChargesAccountNo := GLAccount."No.";
                                NextActionEnabled := true;
                            end;
                        end;

                        trigger OnValidate()
                        begin
                            if ShippingChargesAccountNo = '' then begin
                                NextActionEnabled := false;
                                exit;
                            end;

                            NextActionEnabled := true;
                        end;
                    }
                }
            }
            group(FinishDemoCompany)
            {
                Visible = FinishDemoCompanyStepVisible;
                ShowCaption = false;

                group(Control14)
                {
                    Caption = 'You''re all set!';
                    InstructionalText = 'We''ve already started importing products from your shop in Shopify.';
                }

                group(Control15)
                {
                    Caption = 'Check shop settings';
                    InstructionalText = 'Review your shop settings to ensure that data synchronize correctly.';
                    ShowCaption = false;

                    field(DemoCompanyShopCard; ShopCardLbl)
                    {
                        Caption = 'Shop card';
                        ShowCaption = false;
                        Editable = false;
                        ApplicationArea = All;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"Shpfy Shop Card", Shop);
                        end;
                    }
                }
            }
            group(FinishMyCompany)
            {
                Visible = FinishMyCompanyStepVisible;
                ShowCaption = false;

                group(Control16)
                {
                    Caption = 'You''re all set!';
                    InstructionalText = 'We''ve already started to import data from your shop in Shopify.';
                    Visible = ImportCustomers or ImportProducts;
                }
                group(Control17)
                {
                    Caption = 'You''re all set!';
                    InstructionalText = 'The connection to your shop is working.';
                    Visible = not ImportCustomers and not ImportProducts;
                }

                group(Control18)
                {
                    Caption = 'Check shop settings';
                    InstructionalText = 'Review your shop settings to ensure that your data synchronize correctly.';
                    ShowCaption = false;

                    field(MyCompanyShopCard; ShopCardLbl)
                    {
                        Caption = 'Shop card';
                        ShowCaption = false;
                        Editable = false;
                        ApplicationArea = All;

                        trigger OnDrillDown()
                        begin
                            Page.RunModal(Page::"Shpfy Shop Card", Shop);
                        end;
                    }
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ActionBack)
            {
                ApplicationArea = All;
                Caption = 'Back';
                Enabled = BackActionEnabled;
                Image = PreviousRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(true);
                end;
            }
            action(ActionNext)
            {
                ApplicationArea = All;
                Caption = 'Next';
                Enabled = NextActionEnabled;
                Image = NextRecord;
                InFooterBar = true;
                trigger OnAction();
                begin
                    NextStep(false);
                end;
            }
            action(ActionFinish)
            {
                ApplicationArea = All;
                Caption = 'Finish';
                Enabled = FinishActionEnabled;
                Image = Approve;
                InFooterBar = true;
                trigger OnAction();
                begin
                    FinishAction();
                end;
            }
        }
    }

    trigger OnInit()
    var
        SignupContextValues: Record "Signup Context Values";
        CompanyInformationMgt: Codeunit "Company Information Mgt.";
    begin
        LoadTopBanners();
        EnableControls();

        IsDemoCompany := CompanyInformationMgt.IsDemoCompany();
        if SignupContextValues.Get() then
            IsShopifyContext := SignupContextValues."Signup Context" = "Signup Context"::Shopify;
        if IsShopifyContext then
            ShopUrl := SignupContextValues."Shpfy Signup Shop Url";
        if ShopUrl <> '' then
            if not ShopUrl.StartsWith('https://') then
                ShopUrl := CopyStr('https://' + ShopUrl, 1, 250);
    end;

    trigger OnOpenPage()
    var
        FeatureTelemetry: Codeunit "Feature Telemetry";
    begin
        FeatureTelemetry.LogUptake('0000HUW', 'Shopify', Enum::"Feature Uptake Status"::Discovered);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = Action::OK then
            if not SetupFinished then
                if not Confirm(SetupNotCompletedQst, false) then
                    Error('');
    end;

    var
        MediaRepositoryDone: Record "Media Repository";
        MediaRepositoryStandard: Record "Media Repository";
        MediaResourcesDone: Record "Media Resources";
        MediaResourcesStandard: Record "Media Resources";
        Shop: Record "Shpfy Shop";
        TopBannerVisible: Boolean;
        BackActionEnabled: Boolean;
        FinishActionEnabled: Boolean;
        NextActionEnabled: Boolean;
        Step1Visible: Boolean;
        ConsentStepVisible: Boolean;
        Step2Visible: Boolean;
        Step3Visible: Boolean;
        Step4Visible: Boolean;
        Step5Visible: Boolean;
        Step6Visible: Boolean;
        Step7Visible: Boolean;
        FinishDemoCompanyStepVisible: Boolean;
        FinishMyCompanyStepVisible: Boolean;
        SetupFinished: Boolean;
        IsDemoCompany: Boolean;
        IsShopifyContext: Boolean;
        ConsentVar: Boolean;
        AccessRequested: Boolean;
        CorrectConnection: Boolean;
        SyncScheduled: Boolean;
        ImportProducts: Boolean;
        ImportCustomers: Boolean;
        SyncItemImages: Boolean;
        AutoCreateOrders: Boolean;
        ItemTemplateCode: Code[20];
        CustomerTemplateCode: Code[20];
        ShippingChargesAccountNo: Code[20];
        Step: Option Start,ConsentStep,Step2,Step3,Step4,Step5,Step6,Step7,FinishDemoCompany,FinishMyCompany;
        SetupNotCompletedQst: Label 'The setup is not complete.\\Are you sure you want to exit?';
        ConsentLbl: Label 'By enabling this feature, you consent to your data being shared with a Microsoft service that might be outside of your organization''s selected geographic boundaries and might have different compliance and security standards than Microsoft Dynamics Business Central. Your privacy is important to us, and you can choose whether to share data with the service. To learn more, follow the link below.';
        PrivacyLinkTxt: Label 'https://go.microsoft.com/fwlink/?linkid=521839';
        LearnMoreTok: Label 'Privacy and Cookies';
        ConnectionUnsuccessfulLbl: Label 'Could not connect to Shopify', Comment = 'Shopify must not be translated.';
        ShopCardLbl: Label 'Open shop settings';
        ShopUrl: Text[250];
        ItemConfigTemplateCodeLbl: Label 'SHPFY-ITEM', Locked = true;
        CustomerConfigTemplateCodeLbl: Label 'SHPFY-CUST', Locked = true;
        ItemConfigTemplateDescLbl: Label 'Shopify item template', Comment = 'Shopify must not be translated.';
        CustomerConfigTemplateDescLbl: Label 'Shopify customer template', Comment = 'Shopify must not be translated.';
        CustomerTemplateNotFoundErr: Label 'No customer template was found, please visit Configuration Templates page to create a customer template.';
        ItemTemplateNotFoundErr: Label 'No item template was found, please visit Configuration Templates page to create an item template.';
        InitialImportWaitMsg: Label 'We''re still importing data from your shop.';
        InitialImportTakingLongerMsg: Label 'It looks like this may take a while. You can look around Business Central while we continue to import in the background. Please visit the Shopify Initial Import page to check the status.', Comment = 'Shopify Initial Import is page 30137 "Shpfy Initial Import"';
        InvalidShopUrlErr: Label 'The URL must refer to the internal shop location at myshopify.com. It must not be the public URL that customers use, such as myshop.com.';

    local procedure LoadTopBanners()
    begin
        if MediaRepositoryStandard.Get('AssistedSetup-NoText-400px.png',
           Format(CurrentClientType())) and
           MediaRepositoryDone.Get('AssistedSetupDone-NoText-400px.png',
           Format(CurrentClientType()))
        then
            if MediaResourcesStandard.Get(MediaRepositoryStandard."Media Resources Ref") and
               MediaResourcesDone.Get(MediaRepositoryDone."Media Resources Ref")
            then
                TopBannerVisible := MediaResourcesDone."Media Reference".HasValue();
    end;

    local procedure NextStep(Backwards: Boolean)
    begin
        if (Step = Step::Step2) and not Backwards then begin
            AccessRequested := true;

            CreateShop(Shop);
            Shop.RequestAccessToken();
            Shop.Enabled := true;
            Shop.Modify();

            CorrectConnection := true;
        end;

        repeat
            UpdateStepNumber(Backwards);
        until IsStepAvailable();

        if Step = Step::Step5 then
            ItemTemplateCode := GetItemTemplCode();

        if Step = Step::Step6 then
            CustomerTemplateCode := GetCustomerTemplCode();

        if (Step = Step::FinishDemoCompany) and IsDemoCompany and not Backwards and not SyncScheduled then
            ScheduleInitialImport();

        if (Step = Step::FinishMyCompany) and not IsDemoCompany and not Backwards and not SyncScheduled then begin
            SetShopProperties(Shop);
            Shop.Modify();
            ScheduleInitialImport();
        end;

        EnableControls();
    end;

    local procedure UpdateStepNumber(Backward: Boolean)
    begin
        if Backward then
            Step := Step - 1
        else
            Step := Step + 1;
    end;

    local procedure IsStepAvailable(): Boolean
    begin
        if Step = Step::Step3 then
            if IsDemoCompany then
                exit(false);

        if Step = Step::Step4 then begin
            if IsDemoCompany then
                exit(false);
            if not ImportProducts then
                exit(false);
            if ImportProducts then
                if not ManualProductSetupNeeded() then
                    exit(false);
        end;

        if Step = Step::Step5 then begin
            if IsDemoCompany then
                exit(false);
            if not ImportProducts then
                exit(false);
            if ImportProducts then
                if ManualProductSetupNeeded() then
                    exit(false);
        end;

        if Step = Step::Step6 then begin
            if IsDemoCompany then
                exit(false);
            if not ImportCustomers then
                exit(false);
        end;

        if Step = Step::Step7 then
            if IsDemoCompany then
                exit(false);

        if Step = Step::FinishDemoCompany then
            if not IsDemoCompany then
                exit(false);

        if Step = Step::FinishMyCompany then
            if IsDemoCompany then
                exit(false);

        exit(true);
    end;

    local procedure EnableControls()
    begin
        ResetControls();

        case Step of
            Step::Start:
                ShowStep1();
            Step::ConsentStep:
                ShowConsentStep();
            Step::Step2:
                ShowStep2();
            Step::Step3:
                ShowStep3();
            Step::Step4:
                ShowStep4();
            Step::Step5:
                ShowStep5();
            Step::Step6:
                ShowStep6();
            Step::Step7:
                ShowStep7();
            Step::FinishDemoCompany:
                ShowFinishDemoCompanyStep();
            Step::FinishMyCompany:
                ShowFinishMyCompanyStep();
        end;
    end;

    local procedure ShowStep1()
    begin
        Step1Visible := true;

        BackActionEnabled := false;
        FinishActionEnabled := false;
    end;

    local procedure ShowConsentStep()
    begin
        ConsentStepVisible := true;

        NextActionEnabled := ConsentVar;
        BackActionEnabled := true;
        FinishActionEnabled := false;
    end;

    local procedure ShowStep2()
    begin
        Step2Visible := true;

        if ShopUrl = '' then
            NextActionEnabled := false;
    end;

    local procedure ShowStep3()
    begin
        Step3Visible := true;

        NextActionEnabled := true;
        BackActionEnabled := true;
    end;

    local procedure ShowStep4()
    begin
        Step4Visible := true;

        NextActionEnabled := true;
        BackActionEnabled := true;
    end;

    local procedure ShowStep5()
    begin
        Step5Visible := true;

        if ItemTemplateCode = '' then
            NextActionEnabled := false;
        BackActionEnabled := true;
    end;

    local procedure ShowStep6()
    begin
        Step6Visible := true;

        if CustomerTemplateCode = '' then
            NextActionEnabled := false;
        BackActionEnabled := true;
    end;

    local procedure ShowStep7()
    begin
        Step7Visible := true;

        if ShippingChargesAccountNo = '' then
            NextActionEnabled := false;
        BackActionEnabled := true;
    end;

    local procedure ShowFinishDemoCompanyStep()
    begin
        FinishDemoCompanyStepVisible := true;

        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ShowFinishMyCompanyStep()
    begin
        FinishMyCompanyStepVisible := true;

        NextActionEnabled := false;
        FinishActionEnabled := true;
    end;

    local procedure ResetControls()
    begin
        FinishActionEnabled := false;
        BackActionEnabled := true;
        NextActionEnabled := true;

        Step1Visible := false;
        ConsentStepVisible := false;
        Step2Visible := false;
        Step3Visible := false;
        Step4Visible := false;
        Step5Visible := false;
        Step6Visible := false;
        Step7Visible := false;
        FinishDemoCompanyStepVisible := false;
        FinishMyCompanyStepVisible := false;
    end;

    local procedure FinishAction();
    var
        InitialImport: Codeunit "Shpfy Initial Import";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        GuidedExperience: Codeunit "Guided Experience";
        StartTime: DateTime;
        Dialog: Dialog;
    begin
        SetupFinished := true;
        Commit();
        GuidedExperience.CompleteAssistedSetup(ObjectType::Page, Page::"Shpfy Connector Guide");
        StartTime := CurrentDateTime();
        Dialog.Open(InitialImportWaitMsg);
        while not InitialImport.InitialImportCompleted() do begin
            Sleep(2000);
            if CurrentDateTime() >= StartTime + 10000 then begin
                Message(InitialImportTakingLongerMsg);
                break;
            end;
        end;
        Dialog.Close();
        CurrPage.Close();
        FeatureTelemetry.LogUptake('0000HUX', 'Shopify', Enum::"Feature Uptake Status"::"Set up");
    end;

    local procedure CreateShop(var Shop: Record "Shpfy Shop")
    begin
        if Shop.Get(GetShopCode()) then begin
            Shop.Validate("Shopify URL", ShopUrl);
            if IsDemoCompany then
                SetShopProperties(Shop);
            Shop.Modify();
        end else begin
            Shop.Init();
            Shop.Validate(Code, GetShopCode());
            Shop.Validate("Shopify URL", ShopUrl);
            if IsDemoCompany then
                SetShopProperties(Shop);
            Shop.Insert();
        end;
    end;

    local procedure SetShopProperties(var Shop: Record "Shpfy Shop")
    begin
        Shop.Validate("Allow Background Syncs", true);
        Shop.Validate("Allow Outgoing Requests", false);

        // Item synchronization
        if IsDemoCompany then begin
            Shop.Validate("Item Templ. Code", GetItemTemplCode());
            Shop.Validate("Sync Item Images", Shop."Sync Item Images"::"From Shopify");
        end else
            if ImportProducts then begin
                Shop.Validate("Item Templ. Code", ItemTemplateCode);
                if SyncItemImages then
                    Shop.Validate("Sync Item Images", Shop."Sync Item Images"::"From Shopify");
            end;
        Shop.Validate("Auto Create Unknown Items", true);
        Shop.Validate("Sync Item", Shop."Sync Item"::"From Shopify");

        // Customer synchronization
        if IsDemoCompany then
            Shop.Validate("Customer Templ. Code", GetCustomerTemplCode())
        else
            if ImportCustomers then
                Shop.Validate("Customer Templ. Code", CustomerTemplateCode);
        Shop.Validate("Auto Create Unknown Customers", true);
        Shop.Validate("Customer Import From Shopify", Shop."Customer Import From Shopify"::AllCustomers);

        // Order synchronization
        if IsDemoCompany then begin
            Shop.Validate("Shipping Charges Account", GetShippingChargesGLAccount());
            Shop.Validate("Auto Create Orders", true);
        end else begin
            Shop.Validate("Shipping Charges Account", ShippingChargesAccountNo);
            Shop.Validate("Auto Create Orders", AutoCreateOrders);
        end;
    end;

    local procedure GetShopCode() ShopCode: Code[20]
    var
        StartIndex: Integer;
        EndIndex: Integer;
        Length: Integer;
    begin
        StartIndex := ShopUrl.IndexOf('https://');
        EndIndex := ShopUrl.IndexOf('.myshopify');
        Length := StrLen('https://');
        ShopCode := CopyStr(ShopUrl.Substring(StartIndex + Length, EndIndex - (StartIndex + Length)), 1, MaxStrLen(ShopCode));
        exit(ShopCode);
    end;

    local procedure GetItemTemplCode(): Code[20]
    var
        ItemTempl: Record "Item Templ.";
    begin
        if ItemTempl.Get(ItemConfigTemplateCodeLbl) then
            exit(ItemTempl.Code);

        ItemTempl.SetRange(Type, ItemTempl.Type::Inventory);
        if ItemTempl.FindFirst() then
            exit(CreateItemTemplFromInventoryItemTempl(ItemTempl))
        else
            if IsDemoCompany then
                Error(ItemTemplateNotFoundErr);
    end;

    local procedure GetCustomerTemplCode(): Code[20]
    var
        CustomerTempl: Record "Customer Templ.";
    begin
        if CustomerTempl.Get(CustomerConfigTemplateCodeLbl) then
            exit(CustomerTempl.Code);
        CustomerTempl.SetRange("Contact Type", CustomerTempl."Contact Type"::Person);
        if CustomerTempl.FindFirst() then
            exit(CreateCustomerTemplFromPersonCustomerTempl(CustomerTempl))
        else
            if IsDemoCompany then
                Error(CustomerTemplateNotFoundErr);
    end;

    local procedure CreateCustomerTemplFromPersonCustomerTempl(var OriginalCustomerTempl: Record "Customer Templ."): Code[20]
    var
        NewCustomerTempl: Record "Customer Templ.";
    begin
        NewCustomerTempl.Code := CustomerConfigTemplateCodeLbl;
        NewCustomerTempl.Description := CustomerConfigTemplateDescLbl;
        NewCustomerTempl.Insert(true);
        NewCustomerTempl.CopyFromTemplate(OriginalCustomerTempl);
        exit(NewCustomerTempl.Code);
    end;

    local procedure CreateItemTemplFromInventoryItemTempl(var OriginalItemTempl: Record "Item Templ."): Code[20]
    var
        NewItemTempl: Record "Item Templ.";
    begin
        NewItemTempl.Code := ItemConfigTemplateCodeLbl;
        NewItemTempl.Description := ItemConfigTemplateDescLbl;
        NewItemTempl.Insert(true);
        NewItemTempl.CopyFromTemplate(OriginalItemTempl);
        exit(NewItemTempl.Code);
    end;

    local procedure GetShippingChargesGLAccount(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.SetRange("Direct Posting", true);
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.SetRange("Account Category", GLAccount."Account Category"::Expense);
        if GLAccount.FindFirst() then
            exit(GLAccount."No.");
    end;

    local procedure ScheduleInitialImport()
    var
        InitialImportLine: Record "Shpfy Initial Import Line";
        InitialImport: Codeunit "Shpfy Initial Import";
    begin
        if not SyncScheduled then begin
            InitialImportLine.DeleteAll();
            if IsDemoCompany then
                InitialImport.GenerateSelected(Shop.Code, true, false, true, true)
            else
                InitialImport.GenerateSelected(Shop.Code, ImportProducts, ImportCustomers, SyncItemImages, false);
            InitialImport.Start();
            SyncScheduled := true;
        end;
    end;

    local procedure ManualProductSetupNeeded(): Boolean
    var
        Item: Record Item;
    begin
        ImportProducts := Item.IsEmpty();
        exit(not ImportProducts);
    end;

    local procedure LookupItemTemplateCode(var SelectedItemTemplateCode: Code[20]): Boolean
    var
        ItemTempl: Record "Item Templ.";
    begin
        if Page.RunModal(Page::"Select Item Templ. List", ItemTempl) = Action::LookupOK then begin
            SelectedItemTemplateCode := ItemTempl.Code;
            exit(true);
        end;
    end;

    local procedure LookupCustomerTemplateCode(var SelectedCustomerTemplateCode: Code[20]): Boolean
    var
        CustomerTempl: Record "Customer Templ.";
    begin
        if Page.RunModal(Page::"Select Customer Templ. List", CustomerTempl) = Action::LookupOK then begin
            SelectedCustomerTemplateCode := CustomerTempl.Code;
            exit(true);
        end;
    end;

}