"""Check fw4 defaults and reject legacy dependencies after Kconfig expansion."""
import pathlib
import subprocess
import tempfile
import unittest

ROOT = pathlib.Path(__file__).resolve().parents[1]


class NftablesTest(unittest.TestCase):
    def test_defaults_replace_complete_tokens_and_preserve_other_targets(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            (root / 'include').mkdir()
            target = root / 'include/target.mk'
            target.write_text('DEFAULT_PACKAGES.basic:=base-files\n'
                              'DEFAULT_PACKAGES.router:=\\\n'
                              '\tdnsmasq-full iptables iptables-mod-tproxy ip6tables \\\n'
                              '\tlibip6tc kmod-ipt-nat6 ipset firewall ppp\n'
                              'DEFAULT_PACKAGES.nas:=block-mount\n')
            subprocess.run(['bash', str(ROOT / 'diy-nftables.sh'), str(root)], check=True)
            result = target.read_text()
            self.assertIn('DEFAULT_PACKAGES.basic:=base-files\n', result)
            self.assertIn('DEFAULT_PACKAGES.nas:=block-mount\n', result)
            packages = result.split('DEFAULT_PACKAGES.router:=', 1)[1].split('DEFAULT_PACKAGES.nas', 1)[0].replace('\\', '').split()
            self.assertTrue({'dnsmasq-full', 'ppp', 'firewall4', 'nftables-json', 'kmod-nft-tproxy'} <= set(packages))
            self.assertFalse({'firewall', 'iptables', 'ip6tables', 'ipset', 'libip6tc', 'kmod-ipt-nat6'} & set(packages))
            subprocess.run(['bash', str(ROOT / 'diy-nftables.sh'), str(root)], check=True)
            self.assertEqual(target.read_text(), result)

    def test_missing_defaults_fail_without_rewriting(self):
        with tempfile.TemporaryDirectory() as directory:
            root = pathlib.Path(directory)
            (root / 'include').mkdir()
            target = root / 'include/target.mk'
            target.write_text('DEFAULT_PACKAGES.basic:=base-files\n')
            result = subprocess.run(['bash', str(ROOT / 'diy-nftables.sh'), str(root)], capture_output=True)
            self.assertNotEqual(result.returncode, 0)
            self.assertEqual(target.read_text(), 'DEFAULT_PACKAGES.basic:=base-files\n')

    def test_validator_rejects_legacy_packages_and_missing_fw4(self):
        required = ['firewall4', 'nftables-json', 'dnsmasq_full_nftset', 'luci-app-ssr-plus_Nftables_Transparent_Proxy']
        with tempfile.TemporaryDirectory() as directory:
            config = pathlib.Path(directory) / '.config'
            base = ''.join(f'CONFIG_PACKAGE_{name}=y\n' for name in required)
            config.write_text(base)
            command = ['bash', str(ROOT / 'scripts/validate-fw4.sh'), str(config)]
            self.assertEqual(subprocess.run(command, capture_output=True).returncode, 0)
            for name in ['firewall', 'iptables', 'iptables-mod-tproxy', 'kmod-ipt-core', 'dnsmasq_full_ipset']:
                with self.subTest(package=name):
                    config.write_text(base + f'CONFIG_PACKAGE_{name}=m\n')
                    self.assertNotEqual(subprocess.run(command, capture_output=True).returncode, 0)
            config.write_text(base.replace('CONFIG_PACKAGE_firewall4=y\n', ''))
            self.assertNotEqual(subprocess.run(command, capture_output=True).returncode, 0)


if __name__ == '__main__':
    unittest.main()
