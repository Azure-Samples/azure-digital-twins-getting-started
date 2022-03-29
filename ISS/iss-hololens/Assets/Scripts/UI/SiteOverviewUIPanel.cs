// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using System.Collections.Generic;
using System.Linq;
using Microsoft.MixedReality.Toolkit;
using TMPro;
using UnityEngine;

/// <summary>
/// UI Panel which lists twins
/// </summary>
public class SiteOverviewUIPanel : MonoBehaviour
{
    public TwinGraphData siteData;
    public SiteOverviewButton buttonPrefab;
    public RectTransform contentTransform;
    public TwinUIPanel hoverPanel;
    
    [SerializeField]
    private TextMeshProUGUI latText;
    [SerializeField]
    private TextMeshProUGUI lonText;
    
    private Dictionary<TwinDataScriptableObject, SiteOverviewButton> twinButtons;

    private void Start()
    {
        ClearContent();
        PopulateUIMenu();
        OnHoverEnd();
    }

    private void PopulateUIMenu()
    {
        twinButtons = new Dictionary<TwinDataScriptableObject, SiteOverviewButton>();
        
        foreach (var twinData in siteData.twinData.OrderBy(x=>x.TwinData.Name))
        {
            var button = Instantiate(buttonPrefab, contentTransform);
            button.siteOverviewPanel = this;
            button.TwinData = twinData;
            twinButtons.Add(twinData, button);
        }
    }

    public void SetLatLon(float lat, float lon)
    {
        latText.text = $"{Mathf.Abs(lat):0.0000} °{(lat >= 0 ? "N" : "S")}";
        lonText.text = $"{Mathf.Abs(lon):0.0000} °{(lon >= 0 ? "W" : "E")}";
    }
    
    public void OnHoverButton(TwinDataScriptableObject twinData)
    {
        if (hoverPanel)
        {
            hoverPanel.gameObject.SetActive(true);
            hoverPanel.SetTwinData(twinData);
        }
    }

    public void OnHoverEnd()
    {
        if (hoverPanel)
        {
            hoverPanel.gameObject.SetActive(false);
        }
    }

    private void ClearContent()
    {
        var buttons = GetComponentsInChildren<SiteOverviewButton>();
        foreach (var button in buttons)
        {
            if (Application.isPlaying)
            {
                Destroy(button.gameObject);
            }
            else
            {
                //Make this safe to call outside of playmode
                DestroyImmediate(button.gameObject);
            }
        }
    }
}