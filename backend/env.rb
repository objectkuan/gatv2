# Global variables
#   The source directory of GAT
$ROOT = File.dirname(File.expand_path(__FILE__))
#   The configuration file with repositories
$REPO_CONFIG_FILE = File.join $ROOT, "repos.yaml"
#   The working directory of GAT
$GAT = "/gat/"
$GAT_REPOS = File.join $GAT, "repos/"
$GAT_VOLS = File.join $GAT, "vols/"
$GAT_VOLS_DOCKER = File.join $GAT_VOLS, "docker/"
$GAT_VOLS_KVM = File.join $GAT_VOLS, "kvm/"
#   The Repositories
$REPOS = Hash.new
