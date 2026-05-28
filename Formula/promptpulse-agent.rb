class PromptpulseAgent < Formula
  desc "PromptPulse agent for reporting Codex CLI usage"
  homepage "https://github.com/Gariton/promptpulse-agent-releases"
  version "0.1.0"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/Gariton/promptpulse-agent-releases/releases/download/v0.1.0/promptpulse-agent-macos-arm64.tar.gz"
      sha256 "b333eaf607a499731c85eef09d8094faa36d655f75e0624165e7e1d98024c964"
    end

    on_intel do
      odie "PromptPulse Agent is not available for Intel macOS yet"
    end
  end

  def install
    bin.install "promptpulse-agent"
    (etc/"promptpulse").install "agent.env.example"
  end

  def post_install
    config = etc/"promptpulse/agent.env"
    example = etc/"promptpulse/agent.env.example"
    if !config.exist?
      config.write example.read
      chmod 0600, config
    end
  end

  service do
    run [opt_bin/"promptpulse-agent", "--config", etc/"promptpulse/agent.env"]
    keep_alive true
    log_path var/"log/promptpulse-agent.log"
    error_log_path var/"log/promptpulse-agent.error.log"
    working_dir HOMEBREW_PREFIX
  end

  test do
    system "#{bin}/promptpulse-agent", "--version"
  end
end
