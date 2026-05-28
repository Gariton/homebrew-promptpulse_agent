class PromptpulseAgent < Formula
  desc "PromptPulse agent for reporting Codex CLI usage"
  homepage "https://github.com/Gariton/promptpulse-agent-releases"
  version "0.1.1"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/Gariton/promptpulse-agent-releases/releases/download/v0.1.1/promptpulse-agent-macos-arm64.tar.gz"
      sha256 "f1dc24308f77618d00f6bc931e69bb80ef3e1f0090936e276f67d91d4f9c04d9"
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

  def caveats
    <<~EOS
      Configure this machine's Codex path, device name, and polling interval before starting the service:
        promptpulse-agent config

      Then start the agent:
        brew services start promptpulse-agent
    EOS
  end

  test do
    system "#{bin}/promptpulse-agent", "--version"
  end
end
