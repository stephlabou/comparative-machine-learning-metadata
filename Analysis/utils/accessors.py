import pandas as pd

from utils.crosswalk import property_crosswalk


class BaseAccessor:
    def __init__(self, pandas_obj):
        self._obj = pandas_obj

    def __getattr__(self, attr):
        return self.get(
            getattr(self.crosswalk, attr)
        )

    def get_from_str(self, attr, data):
        # Directly index from DataFrame
        if isinstance(data, pd.DataFrame):
            return data[attr]
        # Index from Series of objects (occurs for nested attributes)
        if isinstance(data, pd.Series):
            # Series of list of dicts
            try:
                return data.apply(lambda li: [d.get(attr) for d in li if d] if li else li)
            except AttributeError:
                # Not a list of dict
                pass

            # Series of dicts
            try:
                return data.apply(lambda d: d.get(attr) if d else d)
            except AttributeError:
                # Not a dict
                pass

            print(data)

    def get_from_tuple(self, attr_tuple, data):
        return pd.concat([self.get(attr, data) for attr in attr_tuple], axis=1)

    def get_from_dict(self, attr_dict, data):
        if len(attr_dict) > 1:
            return self.get(
                (
                    {
                        outer_attr: inner_attr
                        for outer_attr, inner_attr in attr_dict.items()
                    }
                )
            )
        else:
            outer_attr, inner_attr = list(attr_dict.items())[0]
            inner_data = self.get(outer_attr, data)
            return self.get(inner_attr, inner_data)

    def get(self, attr, data=None):
        data = data if data is not None else self._obj
        if isinstance(attr, str):
            return self.get_from_str(attr, data)
        elif isinstance(attr, tuple):
            return self.get_from_tuple(attr, data)
        elif isinstance(attr, dict):
            return self.get_from_dict(attr, data)


@pd.api.extensions.register_dataframe_accessor('DryadRecordsCrosswalk')
class DryadRecordsCrosswalk(BaseAccessor):
    def __init__(self, pandas_obj):
        super().__init__(pandas_obj)
        self.crosswalk = property_crosswalk['dryad']['records']


@pd.api.extensions.register_dataframe_accessor('FigshareArticlesCrosswalk')
class FigshareArticlesCrosswalk(BaseAccessor):
    def __init__(self, pandas_obj):
        super().__init__(pandas_obj)
        self.crosswalk = property_crosswalk['figshare']['articles']


@pd.api.extensions.register_dataframe_accessor('DataverseDatasetsCrosswalk')
class DataverseDatasetsCrosswalk(BaseAccessor):
    def __init__(self, pandas_obj):
        super().__init__(pandas_obj)
        self.crosswalk = property_crosswalk['dataverse']['datasets']


@pd.api.extensions.register_dataframe_accessor('DataverseFilesCrosswalk')
class DataverseFilesCrosswalk(BaseAccessor):
    def __init__(self, pandas_obj):
        super().__init__(pandas_obj)
        self.crosswalk = property_crosswalk['dataverse']['files']


@pd.api.extensions.register_dataframe_accessor('ZenodoRecordsCrosswalk')
class ZenodoRecordsCrosswalk(BaseAccessor):
    def __init__(self, pandas_obj):
        super().__init__(pandas_obj)
        self.crosswalk = property_crosswalk['zenodo']['records']


@pd.api.extensions.register_dataframe_accessor('KaggleDatasetsCrosswalk')
class KaggleDatasetsCrosswalk(BaseAccessor):
    def __init__(self, pandas_obj):
        super().__init__(pandas_obj)
        self.crosswalk = property_crosswalk['kaggle']['datasets']


@pd.api.extensions.register_dataframe_accessor('OpenMLDatasetsCrosswalk')
class OpenMLDatasetsCrosswalk(BaseAccessor):
    def __init__(self, pandas_obj):
        super().__init__(pandas_obj)
        self.crosswalk = property_crosswalk['openml']['datasets']


@pd.api.extensions.register_dataframe_accessor('UCIDatasetsCrosswalk')
class UCIDatasetsCrosswalk(BaseAccessor):
    def __init__(self, pandas_obj):
        super().__init__(pandas_obj)
        self.crosswalk = property_crosswalk['uci']['datasets']
        
@pd.api.extensions.register_dataframe_accessor('UCSDRecordsCrosswalk')
class UCSDRecordsCrosswalk(BaseAccessor):
    def __init__(self, pandas_obj):
        super().__init__(pandas_obj)
        self.crosswalk = property_crosswalk['ucsd']['records']



