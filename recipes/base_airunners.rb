# Setup aiapply (apply all automateit recipes) and aiupgrade (upgrade recipes and apply them)

aiapply   = "/usr/local/bin/aiapply"
aiupgrade = "/usr/local/bin/aiupgrade"
options  = {:mode => 555, :user => "root", :group => "root"}

for filename in [aiapply, aiupgrade]
  cpdist filename, options
end
