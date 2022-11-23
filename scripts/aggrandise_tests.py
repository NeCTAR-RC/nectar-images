# pytest -v aggrandise_tests.py

import pytest
import unittest
from unittest import mock

import aggrandise


class FakeImage(object):

    def __init__(self, id='fake_id', name='Fake', owner='fake_owner',
                 nectar_name='Fake', nectar_build='1', **kwargs):
        self.id = id
        self.name = name
        self.owner = owner
        self.nectar_name = nectar_name
        self.nectar_build = nectar_build

        for k, v in kwargs.items():
            setattr(self, k, v)

    def get(self, key, default=None):
        return getattr(self, key, default)


@mock.patch('aggrandise.Aggrandise.get_session', new=mock.Mock())
class AggrandiseTests(unittest.TestCase):

    @pytest.fixture(autouse=True)
    def capsys(self, capsys):
        """Capsys hook into this class"""
        self.capsys = capsys

    def test_help(self):
        try:
            aggrandise.main(['-h'])
        except SystemExit:
            pass
        captured = self.capsys.readouterr()
        assert "Image workflow tool" in captured.out

    @mock.patch('aggrandise.Aggrandise')
    def test_project_id_with_args(self, mock_iw):
        fake_iw = mock_iw.return_value
        fake_iw.promote = mock.Mock()
        project = 'test_project_id'
        archive_project = 'test_archive_project_id'
        aggrandise.main(['promote', '--image', 'test_image_id', '--project',
                         project, '--archive-project', archive_project])
        fake_iw.promote.assert_called_with(
            image='test_image_id', project=project,
            archive_project=archive_project)

    @mock.patch('aggrandise.Aggrandise')
    def test_project_id_with_envrionment_arg(self, mock_iw):
        fake_iw = mock_iw.return_value
        fake_iw.promote = mock.Mock()
        env = 'rctest'
        project = aggrandise.PROJECT_IDS[env]['project']
        archive_project = aggrandise.PROJECT_IDS[env]['archive_project']
        aggrandise.main(['promote', '--image', 'test_image_id',
                         '--environment', env])
        fake_iw.promote.assert_called_with(
            image='test_image_id', project=project,
            archive_project=archive_project)

    @mock.patch('aggrandise.Aggrandise')
    def test_project_id_without_args(self, mock_iw):
        fake_iw = mock_iw.return_value
        fake_iw.promote = mock.Mock()
        env = 'production'
        project = aggrandise.PROJECT_IDS[env]['project']
        archive_project = aggrandise.PROJECT_IDS[env]['archive_project']
        aggrandise.main(['promote', '--image', 'test_image_id'])
        fake_iw.promote.assert_called_with(
            image='test_image_id', project=project,
            archive_project=archive_project)

    def test_get_archive_name(self):
        image_foo = FakeImage(name='Foo', nectar_build='9')
        iw = aggrandise.Aggrandise()
        assert iw.get_archive_name(image_foo) == 'Foo [v9]'

    def test_archive(self):
        image = FakeImage()
        iw = aggrandise.Aggrandise()
        with mock.patch.object(iw, 'get_glanceclient') as mock_gc:
            fake_client = mock_gc.return_value
            fake_client.images.get.return_value = image
            iw.archive(image.id, archive_project='archive')
            name = f'{image.name} [v{image.nectar_build}]'
            fake_client.images.update.assert_called_with(
                image.id, name=name, visibility='community', owner='archive')

    def test_promote_initial(self):
        image = FakeImage()
        iw = aggrandise.Aggrandise()
        with mock.patch.object(iw, 'get_glanceclient') as mock_gc:
            fake_client = mock_gc.return_value
            fake_client.images.get.return_value = image
            iw.promote(image.id, project='project', archive_project='archive')
            fake_client.images.update.assert_called_with(
                image.id, visibility='public', owner='project')

    def test_promote_missing_build_number(self):
        image = FakeImage()
        delattr(image, 'nectar_build')
        iw = aggrandise.Aggrandise()
        with mock.patch.object(iw, 'get_glanceclient') as mock_gc:
            fake_client = mock_gc.return_value
            fake_client.images.get.return_value = image
            with pytest.raises(AttributeError):
                iw.promote(image.id, project='project',
                           archive_project='archive')

    def test_promote_and_archive(self):
        images = {
           'old1': FakeImage(id='old1', nectar_build='1'),
           'old2': FakeImage(id='old2', nectar_build='2'),
           'new': FakeImage(id='new', nectar_build='3')
        }
        iw = aggrandise.Aggrandise()
        with mock.patch.object(iw, 'get_glanceclient') as mock_gc:
            fake_client = mock_gc.return_value
            fake_client.images.get.side_effect = lambda x: images[x]
            fake_client.images.list.return_value = list(images.values())
            iw.promote('new', project='project', archive_project='archive')
            fake_client.images.update.assert_has_calls([
                mock.call('new', visibility='public', owner='project'),
                mock.call('old1', name=iw.get_archive_name(images['old1']),
                          visibility='community', owner='archive'),
                mock.call('old2', name=iw.get_archive_name(images['old2']),
                          visibility='community', owner='archive'),
            ], any_order=True)

    def test_promote_and_archive_with_dry_run(self):
        args = {'dry_run': True}
        images = {
           'old1': FakeImage(id='old1', nectar_build='1'),
           'old2': FakeImage(id='old2', nectar_build='2'),
           'new': FakeImage(id='new', nectar_build='3')
        }
        iw = aggrandise.Aggrandise(args)
        with mock.patch.object(iw, 'get_glanceclient') as mock_gc:
            fake_client = mock_gc.return_value
            fake_client.images.get.side_effect = lambda x: images[x]
            fake_client.images.list.return_value = list(images.values())
            iw.promote('new', project='project', archive_project='archive')
            fake_client.images.update.assert_not_called()

    def test_archive_with_murano(self):
        image = FakeImage(id='old', nectar_build='1',
                          murano_image_info={'murano': 'True'})
        iw = aggrandise.Aggrandise()
        with mock.patch.object(iw, 'get_glanceclient') as mock_gc:
            fake_client = mock_gc.return_value
            fake_client.images.get.return_value = image
            fake_client.images.list.return_value = [image]
            iw.archive(image.id, archive_project='archive')
            fake_client.images.update.assert_has_calls([
                mock.call(image.id, name=iw.get_archive_name(image),
                          visibility='community', owner='archive'),
                mock.call(image.id, remove_props=['murano_image_info']),
            ])
