from pathlib import Path
from typing import Any, Optional, Union

import numpy as np
import pandas as pd

DataType = Union[dict[Any, Any], pd.DataFrame]


def _attr_as_str(attr: Union[str, tuple, dict], sep: Optional[str] = ':') -> str:
    """Transform a crosswalk property mapping to a string.

    Parameters
    ----------
    attr : str
    sep : str, optional (default=':')
        Value used to separate key and value if attr is a dict.

    Returns
    -------
    str

    Raises
    ------
    TypeError
        attr is not of type (str, dict)
    """

    if isinstance(attr, str):
        return attr
    elif isinstance(attr, dict):
        return f'{list(attr.keys())[0]}{sep}{_attr_as_str(list(attr.values())[0])}'
    else:
        raise TypeError(
            'attr_as_str parameter \'attr\' must be of type '
            f'str, or dict, not \'{type(attr)}\'.'
        )


def retrieve_attribute_by_crosswalk(
        data: Union[DataType, list[DataType]],
        property_attr: Union[str, tuple, dict],
        missing: Optional[Any] = None,
        drop: Optional[Any] = None
) -> Any:
    """Retrieve the data referenced by a crosswalk property.

    Parameters
    ----------
    data : pandas.DataFrame or pandas.Series or dict
        Name-indexed container with the column or columns of data to be retrieved.
    property_attr : str or tuple or dict
        The attribute from a RepositoryCrosswalk that indicates the data. For
        formatting, see the writeup given in the analysis notebook.
    missing : optional (default=None)
        Value to return if data is not present.
    drop : bool
        Flag for dropping None values from the final data set.
        If dropping over a DataFrame, the drop level is set to 'all'

    Returns
    -------
    datum :
        Requested data.

    Raises
    ------
    TypeError
        Incorrect crosswalk_property or df type.
    """

    # property_attr can be None when the repository does not have an attribute matching a crosswalk property.
    # data can be None when looking at nested data.
    if property_attr is None or data is None:
        return missing

    if isinstance(data, pd.Series) and isinstance(data[0], dict):
        return data.apply(lambda row: row.get(property_attr))

    # If the data is a list of objects, recurse over each object
    if isinstance(data, list):
        return [retrieve_attribute_by_crosswalk(inner_data, property_attr, missing) for inner_data in data]

    # If property_attr is a string, directly index it from the data
    if isinstance(property_attr, str):
        try:
            datum = data[property_attr]
        except KeyError:
            datum = missing
    # If property_attr is a tuple, recurse over each element
    elif isinstance(property_attr, tuple):
        attribute_data = dict()
        for individual_attr in property_attr:
            if individual_attr is not None:
                datum = retrieve_attribute_by_crosswalk(data, individual_attr, missing)
                if datum is not None:
                    attribute_data[_attr_as_str(individual_attr)] = datum
        datum = pd.DataFrame(attribute_data)
    # If property_attr is a dict, get the data associated with the key and then recurse over the value
    elif isinstance(property_attr, dict):
        retrieved_data = dict()

        # Get the data for each key, value pair in the dictionary
        for outer_attr, nested_attr in property_attr.items():
            # Retrieve outer attribute data
            inner_data = retrieve_attribute_by_crosswalk(data, outer_attr, missing)
            if isinstance(inner_data[0], dict):
                if not isinstance(nested_attr, tuple):
                    nested_attr = (nested_attr,)
                    for inner_value in nested_attr:
                        retrieved_data[_attr_as_str(inner_value)] = retrieve_attribute_by_crosswalk(
                            inner_data, inner_value, missing
                        )
            elif isinstance(inner_data[0], list):
                if not isinstance(nested_attr, tuple):
                    nested_attr = (nested_attr, )
                for inner_value in nested_attr:
                    datum = list()
                    for inner_list in inner_data:
                        if inner_list:
                            inner_retrieved_data = [
                                retrieve_attribute_by_crosswalk(
                                    inner_dict, inner_value, missing
                                )
                                for inner_dict in inner_list
                            ]
                            if not any(inner_retrieved_data):
                                inner_retrieved_data = []
                            datum.append(inner_retrieved_data)
                        else:
                            datum.append(missing)
                    retrieved_data[_attr_as_str(inner_value)] = datum

        datum = pd.DataFrame(retrieved_data)
    else:
        raise TypeError(
            'property_attr parameter must be of tuple tuple, str, or dict, not '
            f'\'{type(property_attr)}\'.'
        )

    if isinstance(datum, pd.DataFrame):
        datum = datum.squeeze()

    if missing and not drop:
        if isinstance(datum, pd.DataFrame):
            datum = datum.applymap(lambda v: missing if v is None else v)
        elif isinstance(datum, pd.Series):
            datum = datum.apply(lambda v: missing if v is None else v)
        elif isinstance(datum, dict):
            datum = {
                k: (missing if v is None else v)
                for k, v in datum.items()
            }
        else:
            if datum is None:
                datum = missing
    if drop:
        if isinstance(datum, pd.DataFrame):
            datum = datum.dropna(how='all')
        if isinstance(datum, pd.Series):
            datum = datum.dropna()

    return datum


def count_words(string_list: list[str]) -> int:
    return sum([len(s.split(' ')) for s in string_list])


def get_file_extensions(s: pd.Series) -> pd.Series:
    return s.apply(lambda fn: Path(fn).suffixes)


def series_list_to_series(s: pd.Series, dtype: Any) -> pd.Series:
    """Convert pandas Series of list objects to flattened Series."""
    return s.apply(lambda l: pd.Series(l, dtype=dtype)).stack().reset_index(drop=True)


def mean_characters(objects: Any) -> float:
    """Return the mean number of characters for a collection of strings"""
    return pd.Series(objects.apply(lambda s: '' if s is None else s).unique()).apply(len).mean()


def get_summary_statistics(objects: Any, suppress_output: bool = True) -> dict[str, float]:
    """Return the mean, median, and max for a set of objects"""

    summary = {'mean': np.mean(objects), 'median': np.median(objects), 'max': np.max(objects)}
    if not suppress_output:
        for k, v in summary.items():
            print(f'{k}: {v}')
    return summary
