// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.
using Microsoft.MixedReality.Toolkit.Input;
using TMPro;
using UnityEngine;

public class SiteOverviewButton : MonoBehaviour, IMixedRealityFocusHandler
{
    public SiteOverviewUIPanel siteOverviewPanel;

    [Header("UI Components")]
    [SerializeField]
    private TextMeshProUGUI nameLabel;

    [SerializeField]
    private ProgressController progressController;

    [SerializeField]
    private GameObject warningIndicator;

    private TwinDataScriptableObject _twinData;

    public TwinDataScriptableObject TwinData
    {
        get => _twinData;
        set
        {
            _twinData = value;
            _twinData.onDataUpdated += OnDataChanged;
            OnDataChanged();
        }
    }

    [Header("Events")]
    public TwinGameEvent focusOnEvent;

    public TwinGameEvent onHoverStart;
    public TwinGameEvent onHoverEnd;

    private void OnValidate()
    {
        if (_twinData)
        {
            OnDataChanged();
        }
    }

    private void ShowWarningIndicator(bool show)
    {
        warningIndicator.gameObject.SetActive(show);
    }

    private void OnDataChanged()
    {
        nameLabel.text = _twinData.TwinData.Name;
        progressController.CurrentValue = _twinData.TwinData.BarValue;
        progressController.textUnit.text = _twinData.TwinData.BarRangeData.units;
        ShowWarningIndicator(false);
    }

    public void OnClicked()
    {
        focusOnEvent.Raise(_twinData);
    }

    public void OnFocusEnter(FocusEventData eventData)
    {
        siteOverviewPanel.OnHoverButton(TwinData);
        onHoverStart.Raise(TwinData);
    }

    public void OnFocusExit(FocusEventData eventData)
    {
        siteOverviewPanel.OnHoverEnd();
        onHoverEnd.Raise(TwinData);
    }
}