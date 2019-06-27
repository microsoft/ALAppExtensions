// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

page 2504 "Extension Details Part"
{
    Extensible = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    PageType = CardPart;
    PopulateAllFields = true;
    RefreshOnActivate = true;
    ShowFilter = false;
    SourceTable = "NAV App";

    layout
    {
        area(content)
        {
            group(Control8)
            {
                //The GridLayout property is only supported on controls of type Grid
                //GridLayout = Rows;
                ShowCaption = false;
                group(Control2)
                {
                    ShowCaption = false;
                    field(Logo; Logo)
                    {
                        ApplicationArea = All;
                        Caption = 'Logo';
                        Editable = false;
                        ShowCaption = false;
                        ToolTip = 'Specifies the logo of the extension, such as the logo of the service provider.';
                    }
                }
            }
            group(Control4)
            {
                //The GridLayout property is only supported on controls of type Grid
                //GridLayout = Rows;
                ShowCaption = false;
                group(Control9)
                {
                    ShowCaption = false;
                    field(Name; Name)
                    {
                        ApplicationArea = All;
                        Caption = 'Name';
                        MultiLine = true;
                        ToolTip = 'Specifies the name of the extension.';
                    }
                    field(Publisher; Publisher)
                    {
                        ApplicationArea = All;
                        Caption = 'Publisher';
                        MultiLine = true;
                        ToolTip = 'Specifies the person or company that created the extension.';
                    }
                    field(Version; VersionDisplay)
                    {
                        ApplicationArea = All;
                        Caption = 'Version';
                        ToolTip = 'Specifies the version of the extension.';
                    }
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        VersionDisplay :=
          ExtensionInstallationImpl.GetVersionDisplayString(Rec);
    end;

    var
        ExtensionInstallationImpl: Codeunit "Extension Installation Impl";
        VersionDisplay: Text;
}

