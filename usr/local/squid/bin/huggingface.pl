#!/usr/bin/perl

# reference:
#   https://www.squid-cache.org/Doc/config/store_id_program/
# input: 
#   [channel-ID <SP>] URL [<SP> extras]<NL>
# output:
#   [channel-ID <SP>] result [<SP> kv-pairs]
# result can be:
#   OK store-id="..."
#   ERR
#   BH

# Example:
#     https://huggingface.co/lllyasviel/sd-controlnet-openpose/resolve/main/diffusion_pytorch_model.safetensors?download=true
#   redirect to:
#   - https://cdn-lfs.huggingface.co/repos/5e/83/5e831f100c14ae19f2acaf586e01ee1c326e0e7f88d188d1a484cfec5c20f339/a3ca16220ebd7220d37a67d68329b4290f2c72a854955fd35f84b97c85596e5b?response-content-disposition=attachment%3B+filename*%3DUTF-8%27%27diffusion_pytorch_model.safetensors%3B+filename%3D%22diffusion_pytorch_model.safetensors%22%3B&Expires=1711027876&Policy=eyJTdGF0ZW1lbnQiOlt7IkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTcxMTAyNzg3Nn19LCJSZXNvdXJjZSI6Imh0dHBzOi8vY2RuLWxmcy5odWdnaW5nZmFjZS5jby9yZXBvcy81ZS84My81ZTgzMWYxMDBjMTRhZTE5ZjJhY2FmNTg2ZTAxZWUxYzMyNmUwZTdmODhkMTg4ZDFhNDg0Y2ZlYzVjMjBmMzM5L2EzY2ExNjIyMGViZDcyMjBkMzdhNjdkNjgzMjliNDI5MGYyYzcyYTg1NDk1NWZkMzVmODRiOTdjODU1OTZlNWI%7EcmVzcG9uc2UtY29udGVudC1kaXNwb3NpdGlvbj0qIn1dfQ__&Signature=xYJnj2p3gzThLMUw5RGA6d0QaUAntxtwx8uKlLcBZ5bcatBD8pGi9crg%7EvhCXGn6vdVM5drObZUs-QgvmbWslLQyoDjjAScaJIm3mnyDFkyRIsuZjAuFtr0VDQlC2al30SAQlnf1Kp%7EWoNFZupyoY1jZ-UdyHu6yImQ8qg%7EHYYJNWU%7ElLs3eg2SpJaSH2OHi3w8WkWMNeUI56PCd8PsxG3-823mib0kC4afhjNsdYYGbjXi%7EfqnJ4ibIULCdoNPtKMFvN6QlfxjUJ8W82AJohS3KrhzKuGOPiBi9qaD%7ENeC6zY91S4TxzFyeHmq%7E5P4AQHWHRXabyzgEtiRcvY31Nw__&Key-Pair-Id=KVTP0A1DKRTAX
#   - https://cdn-lfs.huggingface.co/repos/5e/83/5e831f100c14ae19f2acaf586e01ee1c326e0e7f88d188d1a484cfec5c20f339/a3ca16220ebd7220d37a67d68329b4290f2c72a854955fd35f84b97c85596e5b?response-content-disposition=attachment%3B+filename*%3DUTF-8%27%27diffusion_pytorch_model.safetensors%3B+filename%3D%22diffusion_pytorch_model.safetensors%22%3B&Expires=1711030012&Policy=eyJTdGF0ZW1lbnQiOlt7IkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTcxMTAzMDAxMn19LCJSZXNvdXJjZSI6Imh0dHBzOi8vY2RuLWxmcy5odWdnaW5nZmFjZS5jby9yZXBvcy81ZS84My81ZTgzMWYxMDBjMTRhZTE5ZjJhY2FmNTg2ZTAxZWUxYzMyNmUwZTdmODhkMTg4ZDFhNDg0Y2ZlYzVjMjBmMzM5L2EzY2ExNjIyMGViZDcyMjBkMzdhNjdkNjgzMjliNDI5MGYyYzcyYTg1NDk1NWZkMzVmODRiOTdjODU1OTZlNWI%7EcmVzcG9uc2UtY29udGVudC1kaXNwb3NpdGlvbj0qIn1dfQ__&Signature=hH3D4ncE9YVQReviffaHqBDvIxcE02yEtbi6cx19QrUlj2DxucHBx5c-TnIpwxVb2KUM-4uzTuS3igsXcqDH-kTkJkkNcnfgJI%7EpZ0-lykWkmwcBZJOZ572yyqadym61VzF6auHF%7Eigtws7juraJCis8iidOBS5csyptmgcodTAHITe0JUov%7E4SdHbUIHGT01Y14g5DcJ18I6wAoqGH6WXMGc0b%7E3HcgAsu4geJvKBSRcrgNTOZP6SS8nbiokfVxnG14MszM0NVoBd9LEUnBvSL7%7Eio4l2tAVlFgP0xrjb9PMm9%7EXYHPltAwargdb2SUFu9P3xPOt34sdc4hlbeO7w__&Key-Pair-Id=KVTP0A1DKRTAX
#   common part:
#     URI Path

# flush stdout
$| = 1; 
# read each line from stdin
while (<>) {
    chomp;
    # print STDERR "IN:" . $_ . "\n";
    @F = split;

    if ($#F < 0) {
        # print STDERR "NOINPUT\n";
        print "ERR\n";
        next;
    }
    
    $url = "";
    if ($#F == 0) {
        # print STDERR "URL ONLY\n";
        $url = $F[0];
    } elsif ($#F > 0) {
        # print STDERR "GOT Channel-ID\n";
        $url = $F[1];
        print $F[0] . " ";
    }
    # print STDERR "URL:" . $url . "\n";

    if ($url =~ m|https://.*.huggingface.co/repos(/[^?]+)|) {
        print "OK store-id=https://huggingface.squid.internal" . $1 . "\n";
    } else {
        print "ERR\n";
    }
}

# some test:
# echo "https://cdn-lfs.huggingface.co/repos/5e/83/5e831f100c14ae19f2acaf586e01ee1c326e0e7f88d188d1a484cfec5c20f339/a3ca16220ebd7220d37a67d68329b4290f2c72a854955fd35f84b97c85596e5b?response-content-disposition=attachment%3B+filename*%3DUTF-8%27%27diffusion_pytorch_model.safetensors%3B+filename%3D%22diffusion_pytorch_model.safetensors%22%3B&Expires=1711027876&Policy=eyJTdGF0ZW1lbnQiOlt7IkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTcxMTAyNzg3Nn19LCJSZXNvdXJjZSI6Imh0dHBzOi8vY2RuLWxmcy5odWdnaW5nZmFjZS5jby9yZXBvcy81ZS84My81ZTgzMWYxMDBjMTRhZTE5ZjJhY2FmNTg2ZTAxZWUxYzMyNmUwZTdmODhkMTg4ZDFhNDg0Y2ZlYzVjMjBmMzM5L2EzY2ExNjIyMGViZDcyMjBkMzdhNjdkNjgzMjliNDI5MGYyYzcyYTg1NDk1NWZkMzVmODRiOTdjODU1OTZlNWI%7EcmVzcG9uc2UtY29udGVudC1kaXNwb3NpdGlvbj0qIn1dfQ__&Signature=xYJnj2p3gzThLMUw5RGA6d0QaUAntxtwx8uKlLcBZ5bcatBD8pGi9crg%7EvhCXGn6vdVM5drObZUs-QgvmbWslLQyoDjjAScaJIm3mnyDFkyRIsuZjAuFtr0VDQlC2al30SAQlnf1Kp%7EWoNFZupyoY1jZ-UdyHu6yImQ8qg%7EHYYJNWU%7ElLs3eg2SpJaSH2OHi3w8WkWMNeUI56PCd8PsxG3-823mib0kC4afhjNsdYYGbjXi%7EfqnJ4ibIULCdoNPtKMFvN6QlfxjUJ8W82AJohS3KrhzKuGOPiBi9qaD%7ENeC6zY91S4TxzFyeHmq%7E5P4AQHWHRXabyzgEtiRcvY31Nw__&Key-Pair-Id=KVTP0A1DKRTAX" | perl genid-civitai.pl
# echo "1 https://cdn-lfs.huggingface.co/repos/5e/83/5e831f100c14ae19f2acaf586e01ee1c326e0e7f88d188d1a484cfec5c20f339/a3ca16220ebd7220d37a67d68329b4290f2c72a854955fd35f84b97c85596e5b?response-content-disposition=attachment%3B+filename*%3DUTF-8%27%27diffusion_pytorch_model.safetensors%3B+filename%3D%22diffusion_pytorch_model.safetensors%22%3B&Expires=1711027876&Policy=eyJTdGF0ZW1lbnQiOlt7IkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTcxMTAyNzg3Nn19LCJSZXNvdXJjZSI6Imh0dHBzOi8vY2RuLWxmcy5odWdnaW5nZmFjZS5jby9yZXBvcy81ZS84My81ZTgzMWYxMDBjMTRhZTE5ZjJhY2FmNTg2ZTAxZWUxYzMyNmUwZTdmODhkMTg4ZDFhNDg0Y2ZlYzVjMjBmMzM5L2EzY2ExNjIyMGViZDcyMjBkMzdhNjdkNjgzMjliNDI5MGYyYzcyYTg1NDk1NWZkMzVmODRiOTdjODU1OTZlNWI%7EcmVzcG9uc2UtY29udGVudC1kaXNwb3NpdGlvbj0qIn1dfQ__&Signature=xYJnj2p3gzThLMUw5RGA6d0QaUAntxtwx8uKlLcBZ5bcatBD8pGi9crg%7EvhCXGn6vdVM5drObZUs-QgvmbWslLQyoDjjAScaJIm3mnyDFkyRIsuZjAuFtr0VDQlC2al30SAQlnf1Kp%7EWoNFZupyoY1jZ-UdyHu6yImQ8qg%7EHYYJNWU%7ElLs3eg2SpJaSH2OHi3w8WkWMNeUI56PCd8PsxG3-823mib0kC4afhjNsdYYGbjXi%7EfqnJ4ibIULCdoNPtKMFvN6QlfxjUJ8W82AJohS3KrhzKuGOPiBi9qaD%7ENeC6zY91S4TxzFyeHmq%7E5P4AQHWHRXabyzgEtiRcvY31Nw__&Key-Pair-Id=KVTP0A1DKRTAX" | perl genid-civitai.pl
# echo "https://cdn-lfs-us-1.huggingface.co/repos/ae/a8/aea888ce05627728879b1954083956ea29cc3158dcdb28c0b7e3e8283ca1fa96/bf56cf2657efb15e465d81402ed481d1e11c4677e4bcce1bc11fe71ad8506b79?response-content-disposition=attachment%3B+filename*%3DUTF-8%27%27sdxl_lightning_4step_lora.safetensors%3B+filename%3D%22sdxl_lightning_4step_lora.safetensors%22%3B&Expires=1711042678&Policy=eyJTdGF0ZW1lbnQiOlt7IkNvbmRpdGlvbiI6eyJEYXRlTGVzc1RoYW4iOnsiQVdTOkVwb2NoVGltZSI6MTcxMTA0MjY3OH19LCJSZXNvdXJjZSI6Imh0dHBzOi8vY2RuLWxmcy11cy0xLmh1Z2dpbmdmYWNlLmNvL3JlcG9zL2FlL2E4L2FlYTg4OGNlMDU2Mjc3Mjg4NzliMTk1NDA4Mzk1NmVhMjljYzMxNThkY2RiMjhjMGI3ZTNlODI4M2NhMWZhOTYvYmY1NmNmMjY1N2VmYjE1ZTQ2NWQ4MTQwMmVkNDgxZDFlMTFjNDY3N2U0YmNjZTFiYzExZmU3MWFkODUwNmI3OT9yZXNwb25zZS1jb250ZW50LWRpc3Bvc2l0aW9uPSoifV19&Signature=OSCEAC9ZY5IzsoUidXQr9Sq3uqUsteYQA0VyYuYLhAX23o9obXYVEYEHeNJUjK7omoh92CFFKzT8YJo9pwISd2pNbgj9wcpUBNs1RR-hNBkXfL%7Ebhomn337NX36koezOeQ7UgWpkac69acsZl3AhYCE9xYZfhzNSPEZVgIgJ0xXTO3SM7jFJUowqR-SdETTuzyiHpq32dcRfnlHkzJZiT2vwSrXhEc0vkR2z-gadT8h5e0qF4l29GdYkuSSzPplFAuHS8ooQwxmmi5d6AjQzCNtlUbRITBLQMCnVG1ISgxK1uwCaqN3oNNwQfr4BQhGOvxiZKrcaUnX8o3A6ddCPHw__&Key-Pair-Id=KCD77M1F0VK2B" | perl genid-civitai.pl


# squid config:
# refresh_pattern -i .+\.squid\.internal/.* 259200 50% 259200 override-lastmod ignore-must-revalidate ignore-reload ignore-no-store ignore-private override-expire
# acl rewritedoms dstdomain .huggingface.co
# store_id_program /usr/local/squid/bin/genid-civitai.pl
# store_id_children 5 startup=1
# store_id_access allow rewritedoms
# store_id_access deny all
