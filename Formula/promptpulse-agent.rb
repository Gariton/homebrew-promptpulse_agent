class PromptpulseAgent < Formula
  desc "PromptPulse agent for reporting Codex CLI usage"
  homepage "https://github.com/Gariton/promptpulse-agent-releases"
  version "0.1.6"
  license :cannot_represent

  on_macos do
    on_arm do
      url "https://github.com/Gariton/promptpulse-agent-releases/releases/download/v0.1.6/promptpulse-agent-macos-arm64.tar.gz"
      sha256 "34a2f98c75bcfa372e0c8c49fd39ce0c1240aef4d903d832d48460f85fb340fe"
    end

    on_intel do
      odie "PromptPulse Agent is not available for Intel macOS yet"
    end
  end

  def install
    agent_binary = Dir["**/promptpulse-agent"].find { |path| File.file?(path) }
    env_example = Dir["**/agent.env.example"].find { |path| File.file?(path) }
    odie "promptpulse-agent binary not found in release archive" if agent_binary.nil?
    odie "agent.env.example not found in release archive" if env_example.nil?

    bin.install agent_binary => "promptpulse-agent"
    pkgshare.mkpath
    File.write(pkgshare/"agent.env.example", File.read(env_example))
  end

  def post_install
    config = etc/"promptpulse/agent.env"
    example = etc/"promptpulse/agent.env.example"
    release_example = pkgshare/"agent.env.example"
    if !example.exist? || example.read.include?("your-project-ref") || example.read.include?("your_publishable_key")
      FileUtils.mkdir_p example.dirname
      File.write(example, release_example.read)
      chmod 0600, example
    end

    if !config.exist?
      File.write(config, example.read)
      chmod 0600, config
    elsif config.read.include?("your-project-ref") || config.read.include?("your_publishable_key")
      example_contents = example.read
      supabase_url = example_contents[/^PROMPTPULSE_SUPABASE_URL=.*$/]
      supabase_key = example_contents[/^PROMPTPULSE_SUPABASE_KEY=.*$/]
      contents = config.read
      contents = contents.gsub(/^PROMPTPULSE_SUPABASE_URL=.*$/, supabase_url)
      contents = contents.gsub(/^PROMPTPULSE_SUPABASE_KEY=.*$/, supabase_key)
      File.write(config, contents)
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
