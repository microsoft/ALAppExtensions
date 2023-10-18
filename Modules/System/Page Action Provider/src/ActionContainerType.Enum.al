// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Integration;

/// <summary>
/// Enumeration used for determining the type of contained actions of a group control.
/// </summary>
enum 2915 "Action Container Type"
{
    /// <summary>
    /// Action container contains new document actions.
    /// </summary>
    value(0; NewDocumentItems) { }

    /// <summary>
    /// Action container contains action items.
    /// </summary>
    value(1; ActionItems) { }

    /// <summary>
    /// Action container contains related information acrions.
    /// </summary>
    value(2; RelatedInformation) { }

    /// <summary>
    /// Action container contains report actions.
    /// </summary>
    value(3; Reports) { }

    /// <summary>
    /// Action container contains home items actions.
    /// </summary>
    value(4; HomeItems) { }

    /// <summary>
    /// Action container contains activity actions.
    /// </summary>
    value(5; ActivityButtons) { }

    /// <summary>
    /// Action container contains department actions.
    /// </summary>
    value(6; Departments) { }

    /// <summary>
    /// Action container contains auto query actions.
    /// </summary>
    value(7; AutoQueryActions) { }

    /// <summary>
    /// Action container contains view actions.
    /// </summary>
    value(8; ViewActions) { }

}

