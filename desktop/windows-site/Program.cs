using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Windows.Forms;
using Microsoft.Web.WebView2.Core;
using Microsoft.Web.WebView2.WinForms;

namespace MediaFlowDesktop;

internal static class Program
{
    [STAThread]
    private static void Main()
    {
        Application.SetHighDpiMode(HighDpiMode.PerMonitorV2);
        Application.EnableVisualStyles();
        Application.SetCompatibleTextRenderingDefault(false);
        Application.Run(new MediaFlowWindow());
    }
}

internal sealed class MediaFlowWindow : Form
{
    private const string Homepage = "https://alexgodly.github.io/MediaFlow/";
    private readonly WebView2 browser;
    private readonly Panel errorPanel;
    private readonly Label errorMessage;
    private readonly Button retryButton;

    public MediaFlowWindow()
    {
        Text = "MediaFlow by Alex Godly";
        BackColor = Color.FromArgb(14, 17, 26);
        ForeColor = Color.White;
        MinimumSize = new Size(320, 420);
        ClientSize = new Size(1260, 800);
        StartPosition = FormStartPosition.CenterScreen;
        AutoScaleMode = AutoScaleMode.Dpi;
        KeyPreview = true;

        browser = new WebView2 {
            Dock = DockStyle.Fill,
            DefaultBackgroundColor = Color.FromArgb(14, 17, 26)
        };
        Controls.Add(browser);

        errorPanel = new Panel { Dock = DockStyle.Fill, BackColor = BackColor, Visible = false };
        var messageBox = new TableLayoutPanel {
            Dock = DockStyle.Fill, ColumnCount = 1, RowCount = 5
        };
        messageBox.RowStyles.Add(new RowStyle(SizeType.Percent, 40));
        messageBox.RowStyles.Add(new RowStyle(SizeType.Absolute, 50));
        messageBox.RowStyles.Add(new RowStyle(SizeType.Absolute, 60));
        messageBox.RowStyles.Add(new RowStyle(SizeType.Absolute, 55));
        messageBox.RowStyles.Add(new RowStyle(SizeType.Percent, 60));
        var heading = new Label {
            Text = "MediaFlow", Font = new Font("Segoe UI", 20, FontStyle.Bold),
            AutoSize = false, Dock = DockStyle.Fill, TextAlign = ContentAlignment.MiddleCenter,
            ForeColor = Color.White
        };
        errorMessage = new Label {
            Text = "The website could not be loaded. Check your internet connection.",
            Dock = DockStyle.Fill, TextAlign = ContentAlignment.MiddleCenter,
            ForeColor = Color.LightGray,
        };
        retryButton = new Button {
            Text = "Retry", FlatStyle = FlatStyle.Flat,
            Width = 130, Height = 38, Anchor = AnchorStyles.None,
            BackColor = Color.FromArgb(55, 77, 125), ForeColor = Color.White
        };
        retryButton.Click += (_, _) => NavigateHome();
        messageBox.Controls.Add(heading, 0, 1);
        messageBox.Controls.Add(errorMessage, 0, 2);
        messageBox.Controls.Add(retryButton, 0, 3);
        errorPanel.Controls.Add(messageBox);
        Controls.Add(errorPanel);
        Shown += async (_, _) => await InitializeBrowserAsync();
        KeyDown += (_, e) => {
            if (e.Alt && e.KeyCode == Keys.Left) { GoBack(); e.Handled = true; }
            else if (e.Control && e.KeyCode == Keys.R) {
                if (browser.CoreWebView2 != null) browser.Reload();
                e.Handled = true;
            }
        };
    }

    private async Task InitializeBrowserAsync()
    {
        try {
            var profileDirectory = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                "MediaFlow by Alex Godly", "WebView2");
            Directory.CreateDirectory(profileDirectory);
            var environment = await CoreWebView2Environment.CreateAsync(
                browserExecutableFolder: null,
                userDataFolder: profileDirectory);
            await browser.EnsureCoreWebView2Async(environment);
            var core = browser.CoreWebView2;
            core.Settings.IsStatusBarEnabled = false;
            core.Settings.AreDevToolsEnabled = false;
            core.Settings.IsBuiltInErrorPageEnabled = true;
            core.Settings.AreDefaultContextMenusEnabled = true;
            core.NewWindowRequested += (_, args) => {
                args.Handled = true;
                if (Uri.TryCreate(args.Uri, UriKind.Absolute, out var uri) &&
                    (uri.Scheme == "https" || uri.Scheme == "http")) {
                    try { Process.Start(new ProcessStartInfo(uri.ToString()) { UseShellExecute = true }); }
                    catch { }
                }
            };
            core.NavigationCompleted += (_, args) => {
                if (args.IsSuccess) {
                    errorPanel.Visible = false;
                } else if (Uri.TryCreate(core.Source, UriKind.Absolute, out var uri) &&
                           uri.Host.Equals("alexgodly.github.io", StringComparison.OrdinalIgnoreCase)) {
                    errorMessage.Text = "Could not reach MediaFlow. Check your connection and retry.";
                    errorPanel.Visible = true;
                    errorPanel.BringToFront();
                }
            };
            browser.Source = new Uri(Homepage);
        } catch (Exception) {
            errorMessage.Text = "Microsoft Edge WebView2 Runtime is required. Install it and retry.";
            errorPanel.Visible = true;
            errorPanel.BringToFront();
        }
    }

    private void NavigateHome()
    {
        if (browser.CoreWebView2 != null) {
            errorPanel.Visible = false;
            browser.CoreWebView2.Navigate(Homepage);
        } else {
            _ = InitializeBrowserAsync();
        }
    }
    private void GoBack()
    {
        if (browser.CanGoBack) browser.GoBack();
    }
}
