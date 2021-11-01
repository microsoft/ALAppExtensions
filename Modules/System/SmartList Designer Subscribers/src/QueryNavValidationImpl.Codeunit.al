#if not CLEAN19
// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 2891 "Query Nav Validation Impl"
{
    Access = Internal;
    ObsoleteState = Pending;
    ObsoleteReason = 'The SmartList Designer is not supported in Business Central.';
    ObsoleteTag = '19.0';

    internal procedure ValidateNavigation(SourceQueryObjectId: Integer; TargetPageId: Integer; LinkingDataItemName: Text; var ValidationResult: Record "Query Navigation Validation"): Boolean
    var
        Args: DotNet ALQueryNavigationValidationArgs;
        Validator: DotNet ALQueryNavigationValidator;
        Result: DotNet ALQueryNavigationValidationResult;
    begin
        Args := Args.ALQueryNavigationValidationArgs();
        Validator := Validator.ALQueryNavigationValidator();

        Args.SourceQueryObjectId(SourceQueryObjectId);
        Args.TargetPageId(TargetPageId);
        Args.LinkingDataItemName(LinkingDataItemName);

        Result := Validator.Validate(Args);

        ValidationResult.Valid := Result.IsValid();

        if not ValidationResult.Valid then
            ValidationResult.Reason := Result.InvalidReason();

        exit(ValidationResult.Valid);
    end;
}
#endif