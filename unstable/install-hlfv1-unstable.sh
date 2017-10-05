ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1-unstable.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1-unstable.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data-unstable"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:unstable
docker tag hyperledger/composer-playground:unstable hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� ���Y �=�r�r�=��fRNR�TN�Oر���&9CIQ>���U�DJ�H�d�x��q8��B�R�T>�T����<�;�y�/�E�$zwM<H$��� ��L��b��̀��l�@G����C�����))��D�G�aa�?-I�=#b,���N�E��# ���űlh��6aW���-{�+-]dZ6����3�����dms �L���3�f�P3����m��?e�6l��f��L�d����D��v�i[.J �ٖ�%l�?�X2����62�!P�pxPɔ?���|n��= ���D�@S��m�v���F6T�	�l�	_·rHߊd$��)�m��4@��u�v��ٴa�zTɤ5#���\v`�	�.�\��3�f��lH�ɠ����h� ް5�:������*�S����#	Y�tŠ��M�xԺ�"��C�bc������|1}�&���YԠn-���v�4Ga6Ud�[:��G���:e�av��P��D�����v\�
󧝖�|�X��+J}8Pê��V'��m̆X�.�U�-���ߴ������LE��9������a����裃,���?6��0�����ǉ�D�o�1�ɲs�eLŶ����5���3���f��ա�{�]��4�>�%����}n+����T�P�O�4t�4���G�����_\���$7D���f̿���{�k_�V�4��G�Ͽ���F�pX�H��±������PM3B5h59;�� ��9PT�O�L�b��WI����rpTNe�
�<����߃NO%�Bt��A��^K�e��Sݧ��Y�_��e��_v�����`�-l�v�'�=��BtJ�ck���B7�����0��؉/�`ԭ�>�Az����,`c@G�s�l@�d��E:��C1�vZ6�8&ݙyt;�օ6e�6ĪLD�k66��i����lo�;~`�-y�tjt�yFic�[Aڞ�6�<t�&6�ϜR^�?]S�a1�2њ&
���(z�Dv��h�ϏrYӱ�R��?��-�;t@-��{o�;� �aEc�W>���[�q�9����4�.����� �G��@Е�� �=�-���u:��@1�)L��	�6и��GbP���Gd�'��'�6�E�D���d|��`�'�z�����������Xi�������@�<Pwv��&�AK�u �����T"`:����K!��Y6�<��8�P�y�\e":|��:xK��C�x��� ��_Q�Y
��Ā�#�(nH�^���}�G"��=
�O���k�xx�8��K�L;9$�f0� P�tt�� ��Qco�, -�C�?b.�����㶜q��"�5���.�,�ǴӮΏ�`�����9Q�YV����>n�V�ޔaC�_<<|r�	e�>�X�:콇.BЕ�f�(�*&�v���V";�������t�ؠ�Ԕ&�̳?�s?Z;ϙp��l�{��@�s��79Q� �A��C��'�qzE�pߨR�O��=M`���+ j&��W�F�S�}@wh^]o�X#p�B��zdA�S����K-3�?�{;�����?�h\X��U���ϗ]f��h.����p|Z�����j��'�G�0�w�-�3���Ӯu�L���vs&��N�c�Y5����>�Ηw>a9᪻�ʇJ��?���L�&�5��=Ϯ���=�<�,1g9pI�ܬ�,�S�3�J����b0r�=�w hp�/��n9mJ�"�4rL6��8�[h>N��n�=�|D��;���V�r����/d��� �Ż�-D&K�6�ua���u�@�B�<��[!�x��)��#~޾Og��3xj"��=�$̹���6(W�iאɃ��bn)i[:&K::=� ް!#�7�C�����i�  ���_����+d�`��N΋軋5����k�o5e��}�e����}n ��D���x$���U����ɧz}O�Nh�]�@�Du��8A�3�Y���s�2C������X��^��x��@���+(���p�$���Fp=�+)7���/;�⑩��Dbk���2��7Cw�� {pӲ2Ml�S3l�h��
rt@]j�M�u����1'�S�;?;���?/>%
~�1A[i:6{��p_wIO���o٨h����"#c�)��*ފ��T��p&����H�{��c�4H�F��f�y������Bl�)�=<�1�a��.R����ke0�:x�3]����8]���,`�Pt����[(7]�����ǥ��H$�����r��T�G�j�p�?t�6ܵ���Q)�큻��a8m=�I<����@@
Aq�o� �{����[����TkM��M��.A��?*Ŧ�?���%�����d��m�ѴA�gB�C?�'����Q���J7����Z���)Y�����U���?w�������)���l H3�������e ��-�.t�a�Ό��sQF�&�g! ���ks���*dm��A� ~�ᨍ���^��]��l)3S�\��l�(k��6�e�IF�d^�/}�t���6�L&�Y���K 1#��Tj���3&�O'˘�c��X.�ɮN%�yz�{P�f�Y�?e^���<3|Dxn�1�df]]�hB��Bdx��g%�nl�W3�������|����p�@����b<�����r��-b���/�Ѡ�����O��D��:�s%�������o����������5�S�營P�&(�Nl�Q���꒲�H��DX
�!�D$ŤD-�(%���X�oEõ�ht�?����57�xC��W���NG׈�B�n�y�x��S�Ka�¦�9���'nch�F����W�jɿ��W#<<���庳6�e����7������'�7'&ټ���6���+�aʈF��xC���7��sϼ[n���ý�ۯ�a����|����&oBc���>�RL����U�+o�5�@�n54���;�aRz��%�d��A7�O�^Om:Y�o_�֠�ly���D%k��juA�oE���V����$�p��m�PP"��@q+51aJR4NHh>�+^AdY�S+@��%��� �)W��|J�fX�;��ϧr穔��r/����\t��⋾J���M\Ù�^���=|��<2��\f�	���ţL�YH.2�r9�(T�T�ج��v-�ځ'���|�>S��c�LK��J;뜆�����E�*�q!p5�K��.3�ٛf��&i�U�絰p����S�f���;c�=���T����+��Åj^8���'���	úw��y�V(Y�T�4}\*�2���G��j��]*Y�+��<9�*�h級9)$Kn�/
�w�Q8��3g�ӓ�9|S<�]fꅤ� �^�tR��IT&ca*Q岶������n��<##�,����JAJȍL.��>�2�����9gk�"Ys��J�p������t��<j��dN����]c�ur��G�S�'�e�ZѴh!~?���[�J<o��r�L��s���y���/��­��e��^���n#-�X�I�����e���h��|��*���|�m�A'��'�������?v�D����R�XA���)w
2�{Ff0%��9J�K)��+���L�c�z��-x���$BM��E<����qr�;NtSj��oT�{1�.��8�3���
��Syg�9.�BA매D������;��|�����`0��������׌��1c�?��S������(Ƅ�#��@�L���obl/�[��WZ>���u���>���벢�_���L����bt���2�'����8���)�}��]b��E6:�z��P�RC�����B	�U�=���c�"�A�܉�w�l)�归v���J�r�즬�Q��)�.�0qy,�S:~QC�ǜt�:���~4�����n8�5R��c�zFa�ȡ����O�V�F�BR�9��]����_N�e�������*�g��N�sw}]�2�x��_��\I��G��|j��g[�L�t�;�H�%�($-��t�!g`�gf��#X;.\�4��%�׍<lGs� {�-�2Hq�go��l9��X��qoo�uivې{⾥�.��n�hT�0-7vv��4g�{�~;���߱1,�k�`��W��z�wTZ�\MyR��7Y\d>Y ��NȺʴ�e��BrOh��a�M`�M{p�r�2��(�-�#���+�F ���Fu��X��Ө.hh��@�mh��~�E-����}�4��i��EN�y w ُ��( ��m��`,����7m���t��f�����(��q�� ѥFG6c	�������v�e�������7�b�� "<���!>��2�#ɝ|h�}0�G��q�v�e:�3�"�t�� ����M�jL�hd"g}�>�P;&��  �Z�G/0���r)�*PEd���^���b��n��� �4a����/�ԐEpg���)mK�,P��1���ۓ)��y}t4����&�~��u���4,/�+����3l�����-P�d�P�6���ф��b�󘚊���#�,�m�H���]�;;�$��[X�����A�|s%y0�"�r���B��m��`��m�����^������G�%0�ա��Ez?�`�=��N�~cR���I���'5sb~ݮ��8��)tt� '��I�}0dK�"�"kf&K5hΩ�|��e������F��'��F��[JإH�C�-F�"�����	�u x]Kt�[��Bn������J�O
;��bw�b��#��\���(������K�j7�W�2_*� �+�����릯��}B�.M��(�������o'T���f�k#�v�.�t`hR�c;t@Ȣ��E����~�F������[��L֔:l4LԠ��ޱu��&�ɊN�V!C���i>>Ƽ�u]�?�a=��T'�8�N۶����n:�� �W�T��n�,��`@>��4b���NG�-�P��1�NH(�� *
}f��CUe��
��y �Xw�&h�&���� �
�1YHc��_�"���?���]K��XZ��i����)R�
f�L7�K����2%�;�s�<�'�+'v'���N�d��B���@Po���Y��alF Do���s�����B���[���}��9��������<~%��~�g�?��.�ŷ'E���?W������o���~G>Ǒ���������譣C�����5t1�ʟ~�Bѐ�H��*�X�
G�r�)IaM<#íA*dT�	�lK�!��_H�x���~��|���~��W~������䏞��8�{�],�;X��G�^�h��_����� ���z/��� ����?"_J���=|�0�O��v�m��{��n��b�S.Z�����n4Z>6�t,��z�l2,}�t:��~/�/X��,�
�-��W!>tUC`Zv�P؍��Z3�XsA��ٝ�V&6�.iB���B�@
��d=[��
�3DH	���N���HkQ(
&g���1[��ǍAl�h]�X74|��L\�����ns����L(�̈́	3�rs�k�T��*n6��i��B�4���E�y�W/��3^����3l��׏��iz���y͠:� S<���S|id�|�k��t"�.T���~�.�쬄��3%Y,SVF�+e�B3Y��"��)�����$����5?]O"L�A��	3�v�I�ْC�Y!��B')�yD�:)��"}.��F�4��05+��"S����yx���*�4߉/&=T+��.q�@汨F.��L��w��.����43���dMk�IJ�UKe�H'�Qz6nRbnn�'��X9�����������^�Mw�^"w�^"wE^"w^"w�]"w�]"wE]"w]"w�\"w�\"wE\"� ��0�.�f)E���O�J�Õ�Rb��9��7��x1���8��60�.��q/jgE�s�*'�K螻�<R�[��۩����@���������A\�S붗yj:Ċ�Hz�3D渁gC�iT�r���f	~����ܔ	�jiZ=G0��S�DY
7��&��	N���Hj��j�����&�'����8c+s�ٲ�#t-��Itoi⭈�Sf�[87/T?:5�r82�1J�a�C�9�)�fbX�vb��(N��<]�D��eS}BᒹӊJ��ܤ�Gd��J�~�̢Ԁ��˼[�w��ہ_8z=�A�(���G�=z��r�?� ���u���n�}���o���&���G��Z>	�s������G�N>��^�:5]���/z�����x#�ׁ�����[�(������+�o<��c>��������<��+EYfi�2YZ�|ވ�r��2y���r�b��ۭ-�/�/Z�'X����8���-3a�3I��Pr!���Ky������\�-�
&�qD�ilJ����]	���o� �D����tZ�������x�BH5J����Ȕ�S�cv�W������T��ln���z�X`��z�mQt|�TZ�8i�F�֣��6H�;*?NWFx�Dj"���L�x����+�4k9M�S���4K��� #�@��P!iAf;��3R�[T�F;*]n'���HĐ��sK�l=Qu�4_�/�SdMQv�)�e8Z�՚���k�&.v˃A�D�	�k9˂�`d-�~�l!���9m�����]f�tÚrܘ3U���-^�J�d�G����ǿu%�ā����B=��|yP�����δ[\n�����e��]���4�K���� �u�#�q��"��"��Y���j#�o?c�gf��e\vGn��.�#����u�{����7�ڴ���
G�[�e:��Ɇ�Vyc֑�|&Oԓ�8�Vla8,)�zܯ���X�.}6�0Ōb4��í��y���è���F��J��lV��*\�ڴe�6��M��6���x��Gt�:��Sȇ�N"5�u���8R힟Z{:��A�|�W:�dZ�R�%��b��҂4=mբy%٨(�T�/��1�.Efi�	�ys �7.5/E�a:��&S�v?�Ry.B�[Åip�X�1#�x�E��³��y%OdE�H+E"dg��xXS#S�1�+��-��l��U$#3I;�d�p�G����4�2An{�*de_�L$k;�*�"0�]�����W+�Rz*�+����X��R�C��Vp�	���c.���*�5
%�Cp�cq�K+ճ(�<Ki���M��et:S��;�
q5��)g��y�)�����E}h:��*��=����	җ�BJܐ��Ba�nF-E�N���|��r�J7D�V����l��5�T�Q���a2j��4�cSi�4���%��P6�-�F�U��r���.c&�.���_|˲���w��M7��ٍ�/Z���.�����<tlѢ���*8r3>�e�g�i�2ԧ��+����7��6�<F~���V��.��{����ϟ?�?|�<�����#ڎ���D� V�>E�΀oISeۇ�]�@\ӛĕ^)�y�y��t���:#��� ���#2�q>A~����)P��8�8uG�k��{�y䁳8�,O]W� x�|�`���ҡG��"�2+G�k��t�t�� Od̯����������H/���G/8���A����ד ���
�;��ts�����T�
�/�Vf��z�;�0V%���4���Ŏܸ��;
���4���3"�_���926ifw��]���H���I�S�k�*��9?�t�l�㧫���3�z�폭�U^Ѣת����U�ɎN��h���s�cj|oo==VG_Q�lH��z?<�HPP� !=����%-�8F�G10E�6��'
,Բ� z& 1�"v*�2H}c�]\ �3�w�ؤaв�S�� �fq.���Ի��&������ �˩O��/O��jNW@���+��V��&>$�MO��`������z�_ g�ADVТ3��1���X뭭u�v �w�W���h~�ʬ��A�|��,] R�̢�'���g�*�L�*�?Yu�b[�h���%���q��{��юW�]�Ip��:�z�"�gm�}��e�tb���2z��$��6�O�aKK�I�8�j8���jQ;�+��@��z!�g䊉+�������ԃ��?�0Ӱ�M���	�����* �.6��u��~�_�/�LF�}=w�_�1t[=:�� ��`S!z,-{�Q�k28� ނ��>�)OB�P��Zm6����6o(�� )�O◧q���粫k@W�g/"��B�m��p~в���dM`e�%�s%k�hٺ2�^���-%O�{��Q�� 8\�a�n]\*��/ ���P�$U�/cX%m �cp.�bz��v_�a�Nv �ݶ��^q�Eo���#�c��� �	����ӔT�=rQ�@�J�&(�񟅜	}�vp��,�]� _�.� Q�6����*�u�ii�~��@����`WV�ce2����C�&͝�\2�o�nZ�<�t;h�Y�$�s�>�n�	r�#��[�E ���D�4kX򪋫�=]�8�	�e��X4(0����.�lto�x����c��� �ކ�8m1���j�i"�-B���W�Z%kݶ�����jBH��:3r
����23��z�:��:�k�'ش_@���1���^�U�͉�	�C��	�z?붉�ֆ�Ɖ�S�9�a1b%)��������_��$�-4egCi�@'(�w���w\qpl��b��Iߑ���j�����
$��܏:�����������������m�����+���b3�'�`��}$��!>!>A@j˶Jv�ܰe%�vr��h �oó�g���"?��g 2�3T1Z�����Q��+\����*vt��R��Y��\��ծu��'���ӱrEC�\�f�H!K�I5	Ij���HdH	�m�j�ZJ�#m\��f��?F��v���p8�H%��}[�����DX�ì�gN,�*�����l�Ƕx�O�'O�Pa̐k�bǂxf��W7��IM����&�bY�qB	�0)&IE�cJ�RQ%$5eBB
Y3�)ሂK��X|Ҵ�����c3�D���̲��o���7�;�$�亣q��	Ovfߓ�E�V�]����wd��cw���msE�+ZT��\�Μer�W�2�d�9�\��/�\�f�"W*=àu�]��[�K'�r�3x�E�����_pa�A��P���3���U�A���.��{��U@@�[;�3�Π���vF�\�'-���i���Z�3��b��-��o�A�6io��;]k�nxl熉Bw�!���V7g�j}��nz��0�b�ߊ�y!��sEy��&��W� t�>���l<Ǯr�<�rL9���"�qY6����P���(
�Y�3i�N�CǶz������Yy��?��m�&<Z�����ZES���e|�,ˉ�\�T�F��e�3����F�X�>���d=�k��bj�g@�=fY-�&��%�9�'K�4C��gq�e.�ϕ�)�q����N�1��E�/�A=�-�O�8��L>kK��\����"�xc0��EL���:Mݝﯡ���,���vs��:߲]��d�X��`��2V��~��0���{�F.u���N���ͮ��;V�ߊw�#�9+3V���@!t����3��m����zq`�&�f�_�$9��G���o��6n��!�|'뿏���KF�f�CD?��>�+���ķ�c���H/��MoI�	zH{H�X�[�*t��{I���'plS����A��#�K�ß��i�ʦ}��K������_ �����hhh^���f��W��#w��:�{I���9&Y����E�v$*����l�Ȗ"K�X$��*�EۡV�����pTib���	�u��,��j�Wa���m���k/�g�m�ɼq�O�}\S��:iet�:G�+b�M	�;�4��u%?��8ɍ��$P=��E��"m.U���rH!2��@��E��-�=�ޖ�����y�?����ޤS)N�Z*^	a1eV��a�;F5��؟�����O���?���_z���Ɔ��8iw����������H���'�������Gڗ�� x���ʧ��?�����[�d$r���H�,�R����+��� ��]��������
�x ��D�O����.�Ij[�S����j��G�Jti_��2�g����?:|��G:��<��<���?���;Q����+�{�j���w��IEE���w1�8�����O�X��N*U�r�U�J%��f�}��Ͽz��P��=�����RP��P�W�������Sw���%�F�����?�����[
ު��k����J]�?gY��_u�NHe;��?�J�?}MHn���u������c���>��y]�D>������Y%D>}l����,����.�YC)��YX����kf�C�sk;M3+��\��t���=��w���Xzȼh����m�c����������m����϶�_m�L�:�^>X��ݮ�K�󄤏�2Iν�f9��[�o�>��n�\ً�0u�H�#'�]QE#��������4-��!��d���Ǧ����S�����r�*ihɈ1��Qf67Ӡ�������iA,�j ��������W�z�?�D��Z���p8��@��?A��?U[�?�8�2P�����W�������?�7������?�&(�?u��a��:�9�o]��{�o�p�O����U�X��N�߸���~u����)�sg<:k�ߗ��[����c�LC�z�I�V�x6WZ����v�VLw�k�=�K+N��kFm�dO�(�Ă��Ͷ3�gd*����fH�&gOe=�׺>�5>���� Q��\}.��h�J���������m㛗84�9��1�)pD%8�:.�K߄Rn��6ev�Nz���m��c�o�:?��&)#�r�D�5�Yg�g�⒑6Z�S�0�E-��@�a���@��2<g�dB�_�������O�z/<�A��ԉ����1������b)�d)��8/DC�c=��Y�'h¥'<%|ڧ����3~u��G��P���_���=G]�b!4[M�F�$c���;�k�kǼ�hi�m�ŗ��ess$��'�#��d�>���62����rrG���B��#EY$ǒd���&��6#*j���Iq����u��C�gu����_A׷R����_u����Oe��?��?.e`�/�D����+뿃n��A���8b"98�ͧm/{;��,g�Sf�%�[�'��/��hЌW?gt�K�n�%����f���!�e���Џ�d���y��١a��uN�?2��d��
�����ߊP�������~���߀:���Wu��/����/����_��h�*P��0w���A������S\�_D��D�-�nxXO��I��X>M����E%�����[�a�\���g� @���3 �?�هg \������P�"�C �<�7����*�l��	��_�Kg7C�VSP���km�)�b��H�z�:���Pz����x�9�ތ݂����"r��まG/O����|�� ��rM��;!�[�E|"���q��4�h���H�<+��n(k$RXV��	��餭f�=o �\bk#����?�Ը���o�?i��5�y����lp��ИNՎ�ә��6HB϶��f�~���E�5C3�[g����~�hr��jc6�N��5���U�3�ދu��@���������}&<�2��[�?�~��b(��(u�}�����RP
�C�_mQ��`����/������������j�0�����?�s=�r=�CIe7���Q�s]��I.dP�fC����i.��˅$b.톰��i�C��h���O)���N�;,%���z�X8B�>��I�sr�oGdA��T�2�k%o�F��l��В��v�ö��٬	����|7飸<7���yD��M�G���CG�m��w"G:-k�G�u�ߋ:��1���?�������k�C���w(�����	��2P������+	���c�x�#��������U����P:���/���5AY������_x3�������������s���d�ĉ�\w��~Q���Ļ��o�����~_C~f����F�q�;���x�w���S-8ț�����k/O����ޑ�'�T/�=-͑���
�Mo91��=��*�����cJc�Is��MFɴ`0�R>��\]X���x��\{��s����v"����z�FP�{�\]oӵ�����P�Ek1ޥ:��#^�mQ1D2S�h�YӐd݂��\s�q��P�����;�A3R"�R�d�w�A�J�ԕ�\㘃�LFZg��Y$9������Xvi�����=8��"����|����������8F@�kE(��a�n�C��`��& ����7���7�C������*�����k�:�?���C����%� uA-����	���_����_������`��W>��Ȯ?���	x�2��G���RP��Q���'���@Y��x�nU���z���B������r�����/5���������?�����(���(e����?���P
 �� ��_=��S������_��(	5��R!�������O�� ����?��T�:����H�(�� ��� ����W���p�
��������W�z�?�C��Z���H�(�� ��� ������?���,�`��*@����_-�����W����KA����KG����0���0���.�
�������+5����]����k�:�?�� �?��:�?�]Ġ����P�a	���\8�I��9'�I�l�>A������y㺜K������/����A�_�T����R�G�����ݹT��?U�B�ݫ7`�*y�'�I���G#N��&6	��x�:�ZR�C�������E��bf��0��e�rE�Q�ȵ�J^!�hi��!u�Z���G�G�|����`��w}�)هsO�Xh�m�h�����IU���u��C�gu����_A׷R����_u����Oe��?��?.e`�/�D����+뿁Ohԩ��[y��QSd���B��Ű}��-lpڟ�T޸/��.���\�E��7,|��+A�:H�l2G���J��SK�6��A�v�v1���6�l5i�'��(�*i�Y�2�C��^���w�;��%�����������u������ �_���_����j�ЀU����a�����|����O��o�O�&#B�;zcN�lqd��(~s���~��{�vWi'	�റ�[>ց�{2���g�7�q�mi��LS/B;����J'����v/��0#Ǫ?�����b�mgD����)Y�þ���Nr�^ۍ��W����t�����a��\.�-�������,��]�ӌ�A���#A�X��ﺡP�#�e}�'�~�����/��&��aN���$m~�1o2����<����wrf���5ڽ���'�m���(X-W�F��x��	�[bٜmR����}w~���]�^�^�������R�����?~�������:�� ���K�g���`ī�(���8��(� ���:�?�b��_�����Ϲ���Q?����������H���+o��%�|p�����ǵ�n&1s�0N�s���:p�'�����ě���,M����&]~ԭW�B>z��Ο,?��~�,?��g�r�������KW��u9�Z�W��Z��9�dl��/N�"|w]5AȯufwC��WŴ��+s #J]��2����2�Ō��q����rѰR�]�9՛���a:���d4o��=c�-�c����[�쓕�侹�[;wu���M��׼�n������!���ħ�D EF,�c��֖h�vS�n��MnD�c�cP�E��|i�,]R�X�\�H�� ��{��
XDv)�;0*�y��'�4��k�\�T�%f#R"!������)zp�^�	�io�#7%ru��sf_Z��������������oI(G�1�z4F�3c1w��c��a���J�(N�f>C��%��)=sC�����,ԡ������?��+�r�_���q�e{+Ed'�MG�`�.a���J�����{��g��|D�\�
�����������P	�_�����^���W
J����Wc�q�������?�_)x���W�����){�ط�X�.3�	��;�ϵ������2P'�ԓ�w5ؐ�y�o�~��xW�y��7�����o����C���D�7;�P`�s�E�ې�A�ZG��Q�5��ר�M;�x��X��4/�����v�?9$���q1Y��Q������C>���l?���zr���ż=k7�Q�a�n;��Jt:KӖ��Ǽ2]��<���x���I�ì��^�0�
'���/%J�R^���K;���S5��J�̐fXs.l�9�
�q�+�.��me6wg��/��:�?����������K���,��Č��k�ϧ/_QL�<�r1�uY��7�E,F�.�Q�G0�#���D�q���#�>���>���ku�u��B�E����BN�<Wj�D�*�}_�-������{�rU-�Ge���g��������A�]�޽�CA���2>��u�Nx�%���������%��s��j�����?�]���P�����?�5���v��1�6�^ڡד�^?���}�C���lMPn����>�
~t;�QZ��[��A$�ɒ	M����|֥�Y_%�ǔ�Ǥo�壅ܻu�����n�+����?}��i�������ض����N�[�n��S'�
Pl�oo��� ��S�_h��Nt&��4���S��� ��{���Z�����]W~]	/�e���Z<-�Q�k�hok��C����`��*]�훭��;ݡo�O�U���ރ���fV�XN�v����i�"f-��O��V�^)�e
M!>��X=��(5!n��}��ԍO�ǛC���n�Q�Z����֮��ۆ-)M��hq�UF�$�͋R]�䀽���ڮaLJS��L�>^�s�������EK�7�v֬���@p�2`Jr]�VR�Q��`�1����Z�$E���z%��3�o����������?��E�oh�����o��˃���O��R�!4������䋐��	�	��	�0���[���9�0�K���m�/�����X��\�ȅ�Q�-�������ߠ�����`��E�^��U�E�����	�6�B�����P�3#������r�?�?z���㿙�J��qA���������������2��C]����#����/��D��."�������P�!������K.�?���/�dJ��B���m�����E���Ȉ<�?d��#��E��D���C&@��� ����������u!���m�����GFN��B "��E��D�a�?�����P������0��	(��б!�1��߶���g�����Lȇ�C�?*r��C�?2 ���!��vɅ�Gr0������<��������۶���E�����2"�op4E��^��f����U�Mư��U,��ɗL�`8ò���la�,�|�#9�c�V��OO���]����/��NO%nިN���.�U�)6e��M���.K���Ze2�ұ�n�����N�"Yяi����m�A�e�B;b��ўl7�EOH��M�j�h��N�� n�����ڡ�P�̹֒ʐ{��i��_�zs��صj�Q�(�������`�$�4ڃ�����߻�(��3���C�Ot����5���<�����#��?�@����O�@ԭp��A���CǏ��D�n�����cb"�X�7
q�0�qܲ���-񻨶������ר�V�y�=Xmt#�z䶶�P������G8گ���~��[��Al�p�jb�]#y5�.ձ����ăj�BO����/��/"P���vo?c����E��!� �� ����C4�6 Bra��܅��� �/�Y����k���-;
j~h{Z�*��*�y����j�n�}>ŊXg2��+�+;P�}=؆�mHE�^o�eI�m�g�q��������mݝ��Hƅ��[>$�9v*x~91ɼ�d�i�Z��6���/j]mW)��C�a���^�M�9[g�p����a^E�?�r�a��5فhWkbר<�)�SQ����^m��9�@��/��onVՊ�د��^�|��OIl���TJ8�Z�6p)�+���*��.��T�B�p�i)�J�R+aBr]|��7KC�h�]�8.n2���M�~z��%y��(�?����� �#�d��k����A!�#r�����/�?2���/k�A������O��?˳��Y�T��$0�p����#��J���dr��8궸E@�A���?s%��3!O�U �'+��������o����P��vɅ�G]��/���$R���m�/��? #7��?"!�?w��KA�G&|3���h��?���oBG��c���&��2.�?�A��F\�>���c�G�X������c�G�a؟��HS?�W��N���9������<���.�[t�~�+��Z��q�*~Ǭ-�X��0�}c^�P���T�i��l���i,N�6�i��G�#�%k|�lj��(�:J�~�?������]�����i�a;�ВҨ��&{[A��ʴ��cA��NB���+8��Ld�,��͈"�gV��$mm�Չn�Yck$Gm���O�݊E�5��,����XY�a(�u��
�X�΀A.�?��Gr���"��������\�?��##O���F2%����_��g����_P�������Ar���"ਛ�&�����\�?K��#"G�e xkr��C�?2���W*i������v�5�H8�\�-{М���������X���'Z{c�[���9M��r ��_>� ���V���64z�()� 8�S�Y�o���6mћ���fH`J��JT�O�ޢY-ڨ�E.no���,+�È�� ,M�39 X��{9 �X�{�b��¢\��.��J��/L�sUl��G!]X����m�ɲޕ�˛����ȤV�kJgi�8�M��
�5���X_�?���Ʌ�G]Y��er���"�[�6�����<���R����������V�-���\��y��i�%u��)��h�,�M�2,R�I�bS�9�\��9�}�����Ƀ�_[�����G��9�g|�aܒ�0���	��i@�4j9���ɬ�V�U͜F�������ћ�Dco?ЪAl�����z��+V��]Դ�~?W�Sɡ�Ӱ�F�A����:1�'U�
.q��rٍ&���k�C��?с��O�B� 7N���Б���d ���E 7uS�$y�����#�?�[�˚ޑU���X�X1�x)��~�!������؉��g���KGv;li��+L�a�2kB���Ƙ���د��	Y�z��c�=����Q[����Y{����К\��������by��,@��, ��\�A�2 �� ��`��?��?`�!����Cķ�qj���g��aa����w,�.��q4ܒ�EH�_��{��������x�PX��N[W�h�i݂��~A���?�w�n�5sTnQ��T�VD�X�J|t��$,6ŶZ(��=4?T�:U�Z۶�^J�������v��	q��d牏ת4�(v�u!N�CY�kbܔ����%��D'�O�Æ_*�n4��RU�t�@�-���c�]E$cL=��'J�Yx� �iV���6�KCz��?m[~���
�4�zu�y=�n�|ِ��|r�S�p\۳c�X^������H�1X�F9zXp{j��6F�����ݝ�L�*N��_�`�n�_xq��;g=���볿��$��_�?ͤ���g��;�MO������S���������mE=�^�5A�)�G�&������q;������g9k�����T���	���v���ĵg���O�ם}�~��~���Bs]s�|()0������������?�V*��槿��}c^���OIT{�r.��3�1�Gq�W�4ͧ����=�/Bw\B�������\�r�0�� ���~��������yx��f�ߙ��=32�ds�9�]`bBO�����6��l��Y4�&n��L�7w�do/8b�������O$����/�Я췇=���������w������<y�{|�/�~}��i���>��'*�
�y~g]�O|���q�N��?�0;���WkI�Z^�׏��͹m��q�#|����В�{ֹ�C<^$��\�qm|��[��;�'���Ŀ��@�>�f�=|��Z�Orw��3������ھ�b��4��ܚ��Y`�_�d��99��}��{/���N�㟟�Ǎ�!�<��x��x�%��Z���&�� ��x���|z��縿uJI�����/��.��v���S��>6��ݪ)�c'wqi�.LE�v�ן����U�LO�N��ҟ���>��'��o��                           .�8_kX � 