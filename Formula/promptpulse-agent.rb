class PromptpulseAgent < Formula
  desc "PromptPulse agent for reporting Codex CLI usage"
  homepage "https://github.com/Gariton/promptpulse-agent-releases"
  url "https://github.com/your-org/codexmeter/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "d3cbbf2275b3a02e137c309a3cf5f79b479f31366ec9da0e78cce6a94394ac22"
  license "MIT"

  depends_on xcode: ["15.0", :build]

  def install
    cd "agents/promptpulse-agent" do
      system "swift", "build", "-c", "release", "--disable-sandbox"
      bin.install ".build/release/promptpulse-agent"
      (etc/"promptpulse").install "packaging/agent.env.example" => "agent.env.example"
    end
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
    assert_match version.to_s, shell_output("#{bin}/promptpulse-agent --version")
  end
end
