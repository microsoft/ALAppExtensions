function RenderTaxInformation(attributes, components) {
    if (window.__TaxInfoLoaded == true) {
        renderData(attributes, components);
    } else {
        window.__TaxInfoData = { attributes: attributes, components: components };
    }
}

function renderData(attributes, components) {
    if (!document.getElementById("controlAddIn"))
        return;

    var attributesEl = document.getElementById("attributes");
    attributesEl.className = 'hidden';

    document.getElementById("nothing-to-show").className = '';
    var tbody = '';
    for (var i = 0; i < attributes.TaxInformation.length; i++) {
        var counter = attributes.TaxInformation[i];
        var row = `<tr>
        <td>${counter.AttributeName} </td>
        <td class="decimal-column">${counter.Value}</td>
        </tr>`;
        tbody = tbody.concat(row);
    }

    if (attributes.TaxInformation.length > 0) {
        document.getElementById("attributes-tbody").innerHTML = tbody.toString();
        attributesEl.className = '';
    }

    var componentsEl = document.getElementById("components");
    componentsEl.className = 'hidden';

    var tbody = '';
    for (var i = 0; i < components.TaxInformation.length; i++) {
        var counter = components.TaxInformation[i];
        var row = `<tr>
        <td > ${counter.Component} </td>
        <td class="decimal-column">${counter.Percent} </td>
        <td class="decimal-column">${counter.Amount} </td>
        </tr>`;
        tbody = tbody.concat(row);
    }

    if (components.TaxInformation.length > 0) {
        document.getElementById("components-tbody").innerHTML = tbody.toString();
        componentsEl.className = '';
    }

    if (attributes.TaxInformation.length != 0 || components.TaxInformation.length != 0)
        document.getElementById("nothing-to-show").className = 'hidden';
}