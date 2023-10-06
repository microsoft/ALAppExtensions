// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxBase;

using Microsoft.Finance.TaxEngine.JsonExchange;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;

codeunit 18551 "Tax Base Tax Engine Setup"
{
    procedure UpgradeUseCaseTree()
    var
        UseCaseTreeIndent: Codeunit "Use Case Tree-Indent";
    begin
        UseCaseTreeIndent.ReadUseCaseTree(GetTreeText());
    end;

    local procedure GetTreeText(): Text
    begin
        exit(UseCaseTreeLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Tax Engine Assisted Setup", 'OnSetupUseCaseTree', '', false, false)]
    local procedure OnSetupUseCaseTree()
    var
        UseCaseTreeIndent: Codeunit "Use Case Tree-Indent";
    begin
        UseCaseTreeIndent.ReadUseCaseTree(GetTreeText());
    end;

    var
        UseCaseTreeLbl: Label 'Use Case Tree Place holder';
}
